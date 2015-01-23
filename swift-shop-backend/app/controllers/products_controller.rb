class ProductsController < ApplicationController

  def index
    products = Product.all
    render json: products.to_json(include: :brand)
  end

end
