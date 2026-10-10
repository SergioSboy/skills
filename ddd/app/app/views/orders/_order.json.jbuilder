json.id order.id
json.status order.status
json.items order.items, partial: "orders/item", as: :item
json.events order.events, partial: "orders/event", as: :event
