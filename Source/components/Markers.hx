package components;

import haxe.ui.components.Label;
import haxe.ui.components.Button;

class Marker {
    public var text:String;
    public var label:Button;
    
    public function new(text:String) {
        this.label = new Button();
        this.label.text = text;
        this.label.addClass("marker");
    }
}

class BuildingMarker { public function new() {} }
class ClickMarker { public function new() {} }
class DeadMarker {

    public var cause:String;

    public function new(cause:String) {
        this.cause = cause;
    }
}

class LootMarker { public function new() {} }
class SmoothMovementMarker { public function new() {} }
class StationaryMarker { public function new() {} }