module Api
  module V1
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :name, :email, :role
    end
  end
end
