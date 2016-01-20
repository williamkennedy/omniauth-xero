require 'omniauth'

module OmniAuth
  module Strategies
    class Xero
      include OmniAuth::Strategy

      args [:consumer_key, :consumer_secret]

      attr_reader :access_token

      def initialize(app, consumer_key, consumer_secret, options = {}, &block)
        @xero = Xeroizer::PartnerApplication.new(
          consumer_key,
          consumer_secret,
          options.delete(:private_key_file),
          options.delete(:ssl_client_cert),
          options.delete(:ssl_client_key),
          options
        )

        super(app, consumer_key, consumer_secret, options, &block)
      end

      def request_phase
        request_token = @xero.client.request_token(oauth_callback: callback_url)

        session['oauth'] ||= {}
        session['oauth'][name.to_s] = {
          'callback_confirmed' => request_token.callback_confirmed?,
          'request_token' => request_token.token,
          'request_secret' => request_token.secret
        }

        authorize_params = {}
        unless request_token.callback_confirmed?
          authorize_params[:oauth_callback] = callback_url
        end

        redirect request_token.authorize_url(authorize_params)
      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      end

      def callback_phase
        fail(OmniAuth::NoSessionError, 'Session Expired') if session['oauth'].nil?

        @xero.client.authorize_from_request(
          session['oauth'][name.to_s]['request_token'],
          session['oauth'][name.to_s]['request_secret'],
          Hash[%w(oauth_verifier oauth_session_handle oauth_expires_in oauth_authorization_expires_in).map{|k| [k.to_sym, request[k]] }]
        )

        @access_token = @xero.client.access_token
        super
      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      rescue ::OAuth::Unauthorized => e
        fail!(:invalid_credentials, e)
      rescue ::OmniAuth::NoSessionError => e
        fail!(:session_expired, e)
      end

      uid { user.user_id }

      info do
        {
          email: user.email_address,
          first_name: user.first_name,
          last_name: user.last_name
        }
      end

      extra do
        {
          access_token: access_token,
          raw_info: {
            user: user,
            organisation: organisation
          }
        }
      end

      credentials do
        {
          token: access_token.token,
          secret: access_token.secret,
          session_handle: @xero.client.session_handle,
          expires_at: @xero.client.expires_at,
          authorization_expires_at: @xero.client.authorization_expires_at
        }
      end

      private

      def user
        @user ||= @xero.User.first(is_subscriber: true)
      end

      def organisation
        @organisation ||= @xero.Organisation.first
      end
    end
  end
end
