class Order < ApplicationRecord
  before_validation :set_total!

  validates :total, presence: true,
                    numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, presence: true

  belongs_to :user
  has_many :placements
  has_many :products, through: :placements

  def set_total!
    self.total = products.map(&:price).sum
  end

  def build_order_from_stock(product_ids_and_quantities)    
    product_ids_and_quantities.each do |product_id_and_quantity|
      id, _quantity = product_id_and_quantity # [1,5]

      self.placements.build(product_id: id)
    end
  end
end
