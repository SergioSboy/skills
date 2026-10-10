class ProductsController < ApplicationController
  def publish
    product = Product.find(params[:id])
    product.publish!
    render :show, formats: [:json], locals: { product: product }
  end
end
