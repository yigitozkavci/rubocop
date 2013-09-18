# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of the Ruby 1.8 hash literal syntax,
      # when the 1.9 syntax is applicable as well.
      #
      # A separate offence is registered for each problematic pair.
      class HashSyntax < Cop
        MSG = 'Ruby 1.8 hash syntax detected'

        def on_hash(node)
          pairs = *node

          sym_indices = pairs.all? { |p| word_symbol_pair?(p) }

          if sym_indices
            pairs.each do |pair|
              if pair.loc.operator && pair.loc.operator.is?('=>')
                convention(pair,
                           pair.loc.expression.begin.join(pair.loc.operator))
              end
            end
          end
        end

        def autocorrect_action(node)
          @corrections << lambda do |corrector|
            replacement = node.loc.expression.source[1..-1]
              .sub(/\s*=>\s*/, ': ')
            corrector.replace(node.loc.expression, replacement)
          end
        end

        private

        def word_symbol_pair?(pair)
          key, _value = *pair

          if key.type == :sym
            sym_name = key.to_a[0]

            sym_name =~ /\A[A-Za-z_]\w*\z/
          else
            false
          end
        end
      end
    end
  end
end
