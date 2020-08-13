# frozen_string_literal: true

module Types
  module Ci
    # rubocop: disable Graphql/AuthorizeTypes
    class GroupType < BaseObject
      graphql_name 'CiGroup'

      field :name, GraphQL::STRING_TYPE, null: true,
        description: 'Name of the job group'
      field :size, GraphQL::INT_TYPE, null: true,
        description: 'Size of the group'
      field :jobs, Ci::JobType.connection_type, null: true,
        description: 'Jobs in group'
    end
  end
end