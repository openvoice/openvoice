module ApplicationHelper
  def sortable(column, title = nil)
     title ||= column.titleize
     css_class = (column == sort_column) ? "current #{sort_direction}" : nil
     direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
     link_to title, params.merge(:sort => column, :direction => direction), {:class => "table " + css_class.to_s}
   end
end
