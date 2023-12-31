#frozen_string_literal: true
module AmazingStore
    class CartonMailer < Spree::BaseMailer

        # Send an email to customers to notify that an individual carton has been
        # shipped. If a carton contains items from multiple orders then this will be
        # called with that carton one time for each order.
        #
        # This custom version also retrieve the estimated time of arrival.
        #
        # @option options carton [Spree::Carton] the shipped carton
        # @option options order [Spree::Order] one of the orders with items in the carton
        # @option options resend [Boolean] indicates whether the email is a 'resend' (e.g.
        #   triggered by the admin "resend" button)
        # @return [Mail::Message]
        def shipped_email(options)
            @order = options.fetch(:order)
            @carton = options.fetch(:carton)
            @manifest = @carton.manifest_for_order(@order)
        
            # Here you can add your custom code to calculate the ETA of the package:
            @eta = DateTime.now + 1.day
        
            options = { resend: false }.merge(options)
            @store = @order.store
            subject = (options[:resend] ? "[#{t('spree.resend').upcase}] " : '')
            subject += "#{@store.name} #{t('spree.shipment_mailer.shipped_email.subject')} ##{@order.number}"
            mail(to: @order.email, from: from_address(@store), subject: subject)
        end
    end
end