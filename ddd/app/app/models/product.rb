class Product < ApplicationRecord
  class InvalidState < StandardError; end

  validates :status, inclusion: { in: %w[draft published] }
  validates :name, presence: true, if: :published?
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, if: :published?

  # В MVC одна ORM-модель содержит правила и сохраняет своё состояние.
  def publish!
    with_lock do
      raise InvalidState, "only draft products can be published" unless status == "draft"
      update!(status: "published")
    end
    self
  end

  private

  def published?
    status == "published"
  end
end
