package components;

import openfl.display.Tile;

class TileImage {
    public var tile:Tile;
    public var isForeground:Bool;
    public var instantChange:Bool;

    public function new(tile:Tile, isForeground:Bool = false) {
        this.tile = tile;
        this.isForeground = isForeground;
        this.instantChange = false;
    }

    public var id(get, set):Int;
    
    private inline function get_id():Int {
        return tile.id;
    }

    private inline function set_id(id:Int):Int {
        return this.tile.id = id;
    }

    public var x(never, set):Float;

    private inline function set_x(x:Float) {
        return this.tile.x = x;
    }    

    public var y(never, set):Float;
    
    private inline function set_y(y:Float) {
        return this.tile.y = y;
    }

}