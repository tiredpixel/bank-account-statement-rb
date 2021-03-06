require_relative '../../base'


module BankAccountStatement
module Inputs
module HTML
module CPBKGB22
module Personal

class Base < HTML::Base
  
  def account
    {
      :id   => _bank_account_ids[:account_id],
      :type => self.class::ACCOUNT_TYPE,
    }
  end
  
  def currency
    :GBP
  end
  
  def transactions
    _transaction_rows.map { |r|
      begin
        posted_at = Date.parse(r[self.class::TH[:date]])
      rescue ArgumentError
        next # annotation line
      end
      
      a = if self.class::TH.has_key?(:amount)
        _clean_amount(r[self.class::TH[:amount]])
      else
        _transaction_amount(
          r[self.class::TH[:deposit]],
          r[self.class::TH[:withdrawal]]
        )
      end
      
      {
        :posted_at => posted_at,
        :type      => _transaction_type(r[self.class::TH[:desc]], a),
        :name      => r[self.class::TH[:desc]].strip,
        :amount    => a,
      }
    }.compact
  end
  
  private
  
  def _clean_str(str)
    str.encode('UTF-8', invalid: :replace, replace: '').strip
  end
  
  def _transaction_amount(deposit, withdrawal)
    d = _clean_amount(deposit)
    w = _clean_amount(withdrawal)
    
    w != 0 ? (w * -1) : d
  end
  
  def _transaction_type(name, amount)
    case name
    when /^BROUGHT FORWARD$/
      :OTHER
    when /^COOP ATM/
      :ATM
    when /^LINK /
      :ATM
    when /^TFR /
      :XFER
    else
      amount >= 0 ? :CREDIT : :DEBIT
    end
  end
  
end

end
end
end
end
end
