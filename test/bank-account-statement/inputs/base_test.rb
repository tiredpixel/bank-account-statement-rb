require 'bigdecimal'
require 'yaml'

require_relative '../../test_helper'
require_relative '../../../lib/bank-account-statement/inputs'


{
  BankAccountStatement::Inputs::HTML::CPBKGB22::Personal::CreditCard::V_2011_04_09 => [
    'HTML/CPBKGB22/Personal/CreditCard/2011-04-09.html',
  ],
  BankAccountStatement::Inputs::HTML::CPBKGB22::Personal::CreditCard::V_2015_05_27 => [
    'HTML/CPBKGB22/Personal/CreditCard/2015-05-27.html',
  ],
  BankAccountStatement::Inputs::HTML::CPBKGB22::Personal::Current::V_2011_05_07 => [
    'HTML/CPBKGB22/Personal/Current/2011-05-07.html',
  ],
  BankAccountStatement::Inputs::HTML::CPBKGB22::Personal::Current::V_2015_03_03 => [
    'HTML/CPBKGB22/Personal/Current/2015-03-03.html',
  ],
  BankAccountStatement::Inputs::HTML::CPBKGB22::Personal::Savings::V_2011_05_07 => [
    'HTML/CPBKGB22/Personal/Savings/2011-05-07.html',
  ],
  BankAccountStatement::Inputs::HTML::CPBKGB22::Personal::Savings::V_2015_03_03 => [
    'HTML/CPBKGB22/Personal/Savings/2015-03-03.html',
  ],
  BankAccountStatement::Inputs::TXT::CPBKGB22::Business::Current::V_2015_12_06 => [
    'TXT/CPBKGB22/Business/Current/2015-12-06.txt',
  ],
}.each do |input_klass, fixtures|
  describe input_klass.name do
    fixtures.each do |fixture|
      it fixture.to_s do
        f = File.expand_path("../#{fixture}", __FILE__)
        y = "#{f}.yaml"
        
        begin
          fc = File.read(f)
        rescue Errno::ENOENT
          skip # this fixture isn't included because of concerns about copyright
        end
        yc = YAML.load_file(y)
        
        input = input_klass.new(fc)
        
        ip = input.parse
        
        ip[:transactions].each_with_index do |transaction, i|
          transaction.must_equal yc[:transactions][i].merge({
            :amount => BigDecimal(yc[:transactions][i][:amount]),
          })
        end
        
        if yc[:balance]
          if yc[:balance][:ledger]
            if x = yc[:balance][:ledger][:amount]
              yc[:balance][:ledger][:amount] = BigDecimal(x)
            end
          end
        end
        
        ip.reject { |k, v|
          k == :transactions
        }.must_equal yc.reject { |k, v|
          k == :transactions
        }
      end
    end
  end
end
