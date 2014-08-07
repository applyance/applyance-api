module Applyance
  class Spot < Sequel::Model

    extend Applyance::Lib::Strings

    many_to_one :entity, :class => :'Applyance::Entity'

    many_to_many :blueprints, :class => :'Applyance::Blueprint'
    many_to_many :applications, :class => :'Applyance::Application'

    def validate
      super
      validates_presence :name
    end

    def after_save
      super

      # Create slug
      # Needs to be unique within the entity, that is all
      self._slug = self.class.to_slug(self.name, '')
      spot_count = self.class.where(:entity_id => self.entity_id, :'_slug' => self._slug).exclude(:id => self.id).count
      self.slug = (spot_count == 0) ? self._slug : "#{self._slug}-#{spot_count + 1}"
    end

  end
end
