
require 'sketchup.rb'


#in sketch pro, create a button. when the button clicked, you can pick a closed pline from the model. ruby code should convert the pline to a component names "property_line" , measure the area within it, then add a customer attribute to the component call "site_area". then stop the button activity.

module RealOptim
  module PropertyLineTool

    def self.activate_property_line_tool
      tool = Object.new

      def tool.onLButtonDown(flags, x, y, view)
        ph = view.pick_helper
        ph.do_pick(x, y)
        edge = ph.best_picked
        
        if edge.is_a?(Sketchup::Edge) && edge.curve && edge.curve.is_a?(Sketchup::ArcCurve)
          # Collect all connected edges forming a closed loop
          edges = edge.curve.edges
          # Create a face temporarily to calculate area
          face = Sketchup.active_model.entities.add_face(edges) rescue nil
          if face
            area = face.area * 0.00064516 # Convert from square inches to square meters
            Sketchup.active_model.entities.erase_entities(face) # Remove temporary face
            
            # Convert the edges to a component
            definition = Sketchup.active_model.definitions.add("Property_Line")
            definition.entities.add_edges(edges.map { |e| [e.start.position, e.end.position] })
            instance = Sketchup.active_model.entities.add_instance(definition, Geom::Transformation.new)
            
            # Add custom attribute with area
            definition.set_attribute("dynamic_attributes", "site_area", area ) 
            
            # Output the area to the Ruby Console for verification
            puts "Site Area: #{area}"
          else
            UI.messagebox("Failed to create a face. Ensure you selected a closed polyline.")
          end
          
          # Deactivate the tool
          Sketchup.active_model.select_tool(nil)
        else
          UI.messagebox("Please select a closed polyline.")
        end
      end

      # Activate the tool
      Sketchup.active_model.select_tool(tool)
    end 

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      menu.add_item('Activate Property Line Tool') {
        self.activate_property_line_tool
      }
      # Create a command for the tool activation
      cmd = UI::Command.new("Activate Property Line Tool") { self.activate_property_line_tool }
      cmd.small_icon = "icons/pick_property_line_24.png" # Path for the small icon
      cmd.large_icon = "icons/pick_property_line_48.png" # Path for the large icon
      cmd.tooltip = "pick a closed polyline from the model"
      cmd.status_bar_text = "pick a closed polyline from the model"
      cmd.menu_text = "pick a closed polyline from the model_menu-text"
      
      # Create a toolbar and add the command
      toolbar = UI::Toolbar.new "Real Estate Development Optimizer"
      toolbar.add_item cmd
      toolbar.show
      file_loaded(__FILE__)
    end # unless file_loaded



  end # module PropertyLineTool
end # module RealOptim
