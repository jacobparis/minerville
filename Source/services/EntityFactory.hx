package services;

import openfl.display.Tile;

import openfl.events.Event;
import openfl.events.MouseEvent;

import ash.core.Entity;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.fsm.EntityStateMachine;
import ash.tools.ComponentPool;

import interfaces.InputListener;

import components.Building;
import components.GameEvent;
import components.GameState;
import components.Hardness;
import components.Health;
import components.Loot;
import components.Marker;
import components.Ore;
import components.Position;
import components.Stationary;
import components.Stimulus;
import components.Task;
import components.TileImage;
import components.TilePosition;
import components.ToolMining;
import components.Worker;



import components.ai.Walking;

import components.markers.ClickedEh;

import enums.EventTypes;
import nodes.WorkerNode;
import nodes.BlockNode;
import nodes.OreNode;
import nodes.TileNode;
import nodes.StationaryObjectNode;

import graphics.AsciiView;

import services.TaskService;
import services.TileMapService;

import util.Point;
import util.Util;
/**
 *  This Service provides the infrastructure to create and register specific 
 *  entities so that I don't need to assemble them from components every time
 *  
 *  As a second function it allows me to attach markers to entities
 *  
 *  As a third function it can test if an entity occupies a specific grid cell
 */
class EntityFactory {
    public static var instance(default, null):EntityFactory = new EntityFactory();

    private var engine:Engine;

    private function new() { }

    public function initialize(engine:Engine):EntityFactory {
        this.engine = engine;
        return this;
    }

    public function destroyEntity(entity:Entity):Void {
        this.engine.removeEntity(entity);
    }

    public function markEntityAtPosition(x:Float, y:Float, marker:String) {
        var entity = testHit(x, y);
        if(entity == null) return;

        entity.add(new ClickedEh());
    }

    /**
     *  Tests if a block is present in a specific pixel
     *  @param x - X Pixel
     *  @param y - Y Pixel
     *  @return Null<Entity>
     */
    public function testHit(x:Float, y:Float):Null<Entity> {
        var nodes:NodeList<TileNode> = engine.getNodeList(TileNode);
        for(node in nodes) {
            var left = (node.position.x + GameConfig.tilesLeft) * GameConfig.tileSize;
            if(x < left) continue;

            var right = left + GameConfig.tileSize;
            if(x > right) continue;

            var top = (node.position.y + GameConfig.tilesUp) * GameConfig.tileSize;
            if(y < top) continue;

            var bottom = top + GameConfig.tileSize;
            if(y > bottom) continue;

            return node.entity;
        }
        return null;
    }

    /**
     *  Tests if a block is present in a specific cell
     *  @param x - X Cell
     *  @param y - Y Cell
     *  @return Null<Entity>
     */
    public function blockAt(x:Float, y:Float):Null<Entity> {
        var nodes:NodeList<TileNode> = engine.getNodeList(TileNode);
        for(node in nodes) {
            if(node.position.x == x
            && node.position.y == y) {
                return node.entity;
            }
        }
        return null;
    }

     /**
     *  Tests if a stationary object is present in a specific cell
     *  @param x - X Cell
     *  @param y - Y Cell
     *  @return Null<Entity>
     */
    public function stationaryAt(x:Float, y:Float):Null<Entity> {
        var nodes:NodeList<StationaryObjectNode> = engine.getNodeList(StationaryObjectNode);
        for(node in nodes) {
            if(node.position.x == x
            && node.position.y == y) {
                return node.entity;
            }
        }
        return null;
    }

    /**
     *  Tests if a worker is present in a specific cell
     *  @param x - X Cell
     *  @param y - Y Cell
     *  @return Null<Entity>
     */
    public function workerAt(x:Float, y:Float):Null<Entity> {
        var nodes:NodeList<WorkerNode> = engine.getNodeList(WorkerNode);
        for(node in nodes) {
            if(node.position.x == x
            && node.position.y == y) {
                if(!node.entity.has(Stationary)) return node.entity;
            }
        }
        return null;
    }

    private function grabEntityFromNode<TNode:Node<TNode>>(nodeClass:Class<TNode>) {
        var node = this.engine.getNodeList(nodeClass).head;

        return (node == null) ? null : node.entity;
    }

    public function findBlock() return grabEntityFromNode(BlockNode);
    public function findOre() return grabEntityFromNode(OreNode);

    /**
     *  Swap two components from one entity to another
     *  @param entity1 - 
     *  @param entity2 - 
     *  @param componentClass - The component to swap
     */
    public function tradeComponents(entity1:Entity, entity2:Entity, componentClass:Class<Dynamic>) {
        var tempComponent = entity1.get(componentClass);
        var temp2Component = entity2.get(componentClass);
		if(tempComponent != null && temp2Component != null) {
            entity1.remove(componentClass);
            entity2.remove(componentClass);
			entity1.add(temp2Component);
			entity2.add(tempComponent);
		} else if (entity1.has(componentClass)) {
			entity2.add(entity1.remove(componentClass));
		} else if (entity2.has(componentClass)) {
			entity1.add(entity2.remove(componentClass));
		}
	}

    public function addStimulus(position:Point, amount:Float = 0.1) {
        var obstruction = stationaryAt(position.x, position.y);
        if(obstruction != null) {
            if(obstruction.has(Stimulus)) {
                obstruction.get(Stimulus).increaseStrength(amount);
            } else obstruction.add(new Stimulus(amount));
        }
    }

    /* Create Game Entity */
    public function createGame():Entity {
        var gameEntity:Entity = new Entity()
        .add(new GameState());

        this.engine.addEntity(gameEntity);
        return gameEntity;
    }

    public function createBuilding(cell:Point, id:Int, name:Buildings):Entity {
        var tile:Tile = new Tile(id);
        var building:Entity = new Entity(name.getName())
        .add(new TilePosition(cell.x, cell.y))
        .add(new TileImage(tile, true))
        .add(new Stationary())
        .add(new Building());

        this.engine.addEntity(building);
        return building;
    }

    public function createBlock(cell:Point, id:Int, health:Int, hardness:Int = 1):Entity {
        var tile:Tile = new Tile(id);
        var block:Entity = new Entity()
        .add(new TilePosition(cell.x, cell.y))
        .add(new Stationary())
        .add(new TileImage(tile))
        .add(new Hardness(hardness))
        .add(new Health(health));

        this.engine.addEntity(block);
        return block;
    }

    public function createWorker(?name:String):Entity {
        var base:Entity = this.engine.getEntityByName(Buildings.BASE.getName());
        var position:TilePosition = base.get(TilePosition);
        var tile:Tile = new Tile(6);
        var worker:Entity = new Entity(name)
        .add(new TilePosition(position.x + Util.anyOneOf([-1, 1]), position.y + Util.anyOneOf([-1, 1])))
        .add(new TileImage(tile, true))
        .add(new Worker());
        
        this.engine.addEntity(worker);
        return worker;
    }

    public function createMiningTool(strength:Int):Entity {
        var base:Entity = this.engine.getEntityByName(Buildings.BASE.getName());
        var position:TilePosition = base.get(TilePosition);
        var tool:Entity = new Entity()
        .add(new TilePosition(position.x + Util.anyOneOf([-1, 1]), position.y + Util.anyOneOf([-1, 1])))
        .add(new TileImage(new Tile(9), true))
        .add(new Loot())
        .add(new ToolMining(strength));

        this.engine.addEntity(tool);
        return tool;
    }

    public function createOre(cell:Point, id:Int):Entity {
        var tile:Tile = new Tile(id);
        var ore:Entity = new Entity()
        .add(new TilePosition(cell.x, cell.y))
        .add(new Stationary())
        .add(new TileImage(tile, true))
        .add(new Loot())
        .add(new Ore(id));

        this.engine.addEntity(ore);
        return ore;
    }

    public function dropLoot<T>(cell:Point, lootComponent:T) {
        var id = 0;
        switch(Type.getClass(lootComponent)) {
            case Ore: id = 8;
            case ToolMining: id = 9;
        }
        var neighbours = [new Point(1, 0), new Point(1, -1), new Point(0, -1), new Point(-1, -1), new Point(-1, 0), new Point(-1, 1),new Point(0, 1), new Point(1, 1)];
        var position = cell.clone().addPoint(Util.anyOneOf(neighbours));
        var loot:Entity = new Entity()
        .add(new TilePosition(position.x, position.y))
        .add(new TileImage(new Tile(id), true))
        .add(new Loot())
        .add(lootComponent);

        this.engine.addEntity(loot);
        return loot;
    }
    public function getWalkingToBase():Task {
        var base:Entity = this.engine.getEntityByName(Buildings.BASE.getName());

        return new Task(Skills.WALK, base);
    }
}

enum Buildings {
    BASE;
    REFINERY;
    FACTORY;
    SILO;
    HOUSE;
}

enum Workers {
    WORKER;
    MINER;
    WARRIOR;
}