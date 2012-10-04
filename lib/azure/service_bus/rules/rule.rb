#-------------------------------------------------------------------------
# Copyright 2012 Microsoft Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
require "azure/service_bus/core/error_handler"
require "nokogiri"

module Azure
  module ServiceBus
    module Rules
      class Rule
        include Core::ErrorHandler

        # Get the Rule's name.
        attr :name

        # Get Rule Subscription.
        attr :subscription

        # Get/Set filter hash.
        attr_accessor :filter

        # Get/Set action hash.
        attr_accessor :action

        # Public: Initialize Rule from a XML document.
        #
        # doc - An instance of Nokogiri::XML::Document.
        #
        # Returns an instance of Rule.
        def self.from_document(doc, subscription)

          name = (doc % "title").text

          elements = ["Filter", "Action"]

          elements.map! do |element_name|
            node = (doc % element_name)
            hash = {}
            key = node["type"]
            hash[key] = {}
            node.children.each do |child|
              hash[key][child.name] = child.content
            end
            hash
          end

          filter = elements.first
          action = elements.last

          new(name, subscription, filter, action)
        end

        # Public: Initialize Rule object.
        #
        # name   -  String representing the name of the Rule.
        # filter - A Hash representing `filter` option.
        #
        #          Example:
        #
        #          {"SqlFilterExpression" => {
        #            "SqlExpression" => "MyProperty='XYZ'"
        #          }}
        #
        #          Becomes:
        #
        #          <Filter i:type="SqlFilterExpression">
        #            <SqlExpression>MyProperty='XYZ'</SqlExpression>
        #          </Filter>
        #
        # action - A Hash representing `action` option.
        #
        #          Example:
        #
        #          {"SqlFilterAction" => {
        #            "SqlExpression" => "set MyProperty2 = 'ABC'"
        #          }}
        #
        #          Becomes:
        #
        #          <Action i:type="SqlFilterAction">
        #            <SqlExpression>set MyProperty2 = 'ABC'</SqlExpression>
        #          </Action>
        def initialize(name, subscription=nil, filter={}, action={})
          @name = name
          @subscription = subscription
          @filter = filter
          @action = action
          yield self if block_given?
        end

        # Public: Deletes the Rule.
        #
        # Returns Boolean indicating success.
        def delete(service=Azure::ServiceBus::Rules)
          service.delete(self)
        end
      end
    end
  end
end
