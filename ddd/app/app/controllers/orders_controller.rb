class OrdersController < ApplicationController
  def confirm
    repository = Orders::Repositories::ActiveRecordOrderRepository.new
    order = Orders::Application::ConfirmOrder.new(repository: repository).call(order_id: params[:id])
    render :show, formats: [:json], locals: { order: order }
  end
end
