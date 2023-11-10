# frozen_string_literal: true

module AmazingStore
    module Calculator
      module Returns
        class WithPenalty < Spree::Calculator::Returns::DefaultRefundAmount
          def compute(return_item)
            default = super
            case days_since_order(return_item)
            when 0..7
              default
            when 8..14
              default * 0.75
            else
              default * 0.5
            end
          end
  
          private
  
          def days_since_order(return_item)
            (Date.today - return_item.inventory_unit.order.created_at.to_date).to_i
          end
        end
      end
    end
  end