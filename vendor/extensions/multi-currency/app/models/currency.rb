require "money"
class Currency < ActiveRecord::Base

  has_many :currency_converters do
    def get_rate(date)
      last(:conditions => ["date_req <= ?", date])
    end
  end

  default_scope :order => "currencies.locale"
  scope :locale, lambda{|str| where("locale like ?", "%#{str}%")}
  after_save :reset_basic_currency

  def basic!
    self.class.update_all(:basic => false) && update_attribute(:basic, true)
  end

  def locale=(locales)
    write_attribute(:locale, [locales].flatten.compact.join(','))
  end

  def locale(need_split = true)
    need_split ? read_attribute(:locale).to_s.split(',') : read_attribute(:locale).to_s
  end

  def reset_basic_currency
    self.class.where("id != ?", self.id).update_all(:basic => false) if self.basic?
  end

  class << self


    def current( current_locale = nil )
      @current = locale(current_locale || I18n.locale).first
    end

    def current!(current_locale = nil )
      @current = current_locale.is_a?(Currency) ? current_locale : locale(current_locale||I18n.locale).first
    end

    def load_rate(options= {})
      current(options[:locale] || I18n.locale)
      basic

      if @rate = @current.currency_converters.get_rate(options[:date] || Time.now)
        add_rate(@basic.char_code,   @current.char_code, @rate.nominal/@rate.value.to_f)
        add_rate(@current.char_code, @basic.char_code,   @rate.value.to_f)
      end

    end

    def convert(value, from, to)
      ( Money.new(value.to_f * 10000, from).exchange_to(to).to_f / 100).round(2)
    end


    def conversion_to_current(value, options = { })
      load_rate(options)
      convert(value, @basic.char_code, @current.char_code)
      #convert(value, @basic.char_code, "USD")
    rescue => ex
      Rails.logger.error " [ Currency ] :#{ex.inspect}"
      value
    end


    #Currency.conversion_from_current(100, :locale => "ru")
    def conversion_from_current(value, options={})
      load_rate(options)
      convert(value,  @current.char_code, @basic.char_code)
    rescue => ex
      Rails.logger.error " [ Currency ] :#{ex.inspect}"
      value
    end


    def basic
      @basic ||= where(:basic => true).first
    end

    def get(num_code, options ={ })
      find_by_num_code(num_code) || create(options)
    end

    private

    def add_rate(from, to, rate)
      Money.add_rate(from, to, rate.to_f ) unless Money.default_bank.get_rate(from, to)
    end

  end # end class << self

end
