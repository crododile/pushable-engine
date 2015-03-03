module Pushable
  class Device < ActiveRecord::Base
    belongs_to :pushable, polymorphic: true

    validates :token, presence: true, uniqueness: { scope: :pushable }
    validates :platform, inclusion: { in: %w(ios android) }

    before_save :reset_token_expiry

    def reset_token_expiry
      self.token_expires_at = Time.current + expire_token_in
    end

    def expire_token_in
      14.days
    end

    def token_expired?
      token_expires_at.nil? || token_expires_at.past?
    end

    def self.android
      where(platform: 'android')
    end

    def self.ios
      where(platform: 'ios')
    end

    def self.owned_by(pushable)
      klass = pushable.klass.name
      table = pushable.table.name
      joins("JOIN #{table} ON #{table}.id = pushable_devices.pushable_id").
        where(pushable_type: klass).
        merge(pushable).
        uniq
    end

  end
end
