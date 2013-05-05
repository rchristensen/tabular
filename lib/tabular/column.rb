module Tabular
  class Column
    include Tabular::Keys

    attr_reader :key, :column_type

    def initialize(table, columns, key = nil, columns_map = {})
      @columns = columns
      @table = table

      key = symbolize(key)
      columns_map = columns_map || {}
      map_for_key = columns_map[key]

      @column_type = :string
      case map_for_key
      when nil
        @key = key
        @column_type = :date if key == :date
      when Symbol
        @key = map_for_key
        @column_type = :date if key == :date
      when Hash
        @key = key
        @column_type = map_for_key[:column_type]
      else
        raise "Expected Symbol or Hash, but was #{map_for_key.class}"
      end
    end

    def symbolize(key)
      return nil if key.blank?

      begin
        key.to_s.strip.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          gsub(/ +/, "_").
          downcase.
          to_sym
      rescue
        nil
      end
    end

    def rows
      @table.rows
    end

    def cells
      rows.map { |r| r[key] }
    end

    def max
      cells.compact.max
    end

    def precision
      @precision || cells.map(&:to_f).map {|n| n.round(3) }.map {|n| n.to_s.split(".").last.gsub(/0+$/, "").length }.max
    end

    def render
      renderer.render_header self
    end

    def renderer
      @columns.renderer(key)
    end

    def inspect
      "#<Tabular::Column #{key} #{column_type}>"
    end

    def to_s
      key
    end
  end
end
