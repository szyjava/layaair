package PathFinding.finders
{
	import PathFinding.core.DiagonalMovement;
	import PathFinding.core.Grid;
	import PathFinding.core.Heuristic;
	import PathFinding.core.Node;
	import PathFinding.core.Util;
	import PathFinding.libs.Heap;
	
	/**
	 * ...
	 * @author dongketao
	 */
	public class AStarFinder
	{
		private var allowDiagonal:Boolean;
		private var dontCrossCorners:Boolean;
		private var heuristic:Function;
		private var weight:int;
		private var diagonalMovement:int;
		
		/**
		 * A* path-finder. Based upon https://github.com/bgrins/javascript-astar
		 * @constructor
		 * @param {Object} opt
		 * @param {boolean} opt.allowDiagonal Whether diagonal movement is allowed.
		 *     Deprecated, use diagonalMovement instead.
		 * @param {boolean} opt.dontCrossCorners Disallow diagonal movement touching
		 *     block corners. Deprecated, use diagonalMovement instead.
		 * @param {DiagonalMovement} opt.diagonalMovement Allowed diagonal movement.
		 * @param {function} opt.heuristic Heuristic function to estimate the distance
		 *     (defaults to manhattan).
		 * @param {number} opt.weight Weight to apply to the heuristic to allow for
		 *     suboptimal paths, in order to speed up the search.
		 */
		public function AStarFinder(opt:Object)
		{
			opt = opt || {};
			this.allowDiagonal = opt.allowDiagonal;
			this.dontCrossCorners = opt.dontCrossCorners;
			this.heuristic = opt.heuristic || Heuristic.manhattan;
			this.weight = opt.weight || 1;
			this.diagonalMovement = opt.diagonalMovement;
			
			if (!this.diagonalMovement)
			{
				if (!this.allowDiagonal)
				{
					this.diagonalMovement = DiagonalMovement.Never;
				}
				else
				{
					if (this.dontCrossCorners)
					{
						this.diagonalMovement = DiagonalMovement.OnlyWhenNoObstacles;
					}
					else
					{
						this.diagonalMovement = DiagonalMovement.IfAtMostOneObstacle;
					}
				}
			}
			
			// When diagonal movement is allowed the manhattan heuristic is not
			//admissible. It should be octile instead
			if (this.diagonalMovement === DiagonalMovement.Never)
			{
				this.heuristic = opt.heuristic || Heuristic.manhattan;
			}
			else
			{
				this.heuristic = opt.heuristic || Heuristic.octile;
			}
		}
		
		/**
		 * Find and return the the path.
		 * @return {Array<Array<number>>} The path, including both start and
		 *     end positions.
		 */
		public function findPath(startX:int, startY:int, endX:int, endY:int, grid:Grid):Array
		{
			var openList:Heap = new Heap(function(nodeA:Node, nodeB:Node):int
			{
				return nodeA.f - nodeB.f;
			}), startNode:Node = grid.getNodeAt(startX, startY), endNode:Node = grid.getNodeAt(endX, endY), heuristic:Function = this.heuristic, diagonalMovement:int = this.diagonalMovement, weight:int = this.weight, abs:Function = Math.abs, SQRT2:Number = Math.SQRT2, node:Node, neighbors:Array, neighbor:Node, i:int, l:int, x:int, y:int, ng:int;
			
			// set the `g` and `f` value of the start node to be 0
			startNode.g = 0;
			startNode.f = 0;
			
			// push the start node into the open list
			openList.push(startNode);
			startNode.opened = true;
			
			// while the open list is not empty
			while (!openList.empty())
			{
				// pop the position of node which has the minimum `f` value.
				node = openList.pop() as Node;
				node.closed = true;
				
				// if reached the end position, construct the path and return it
				if (node === endNode)
				{
					return Util.backtrace(endNode);
				}
				
				// get neigbours of the current node
				neighbors = grid.getNeighbors(node, diagonalMovement);
				for (i = 0, l = neighbors.length; i < l; ++i)
				{
					neighbor = neighbors[i];
					
					if (neighbor.closed)
					{
						continue;
					}
					
					x = neighbor.x;
					y = neighbor.y;
					
					// get the distance between current node and the neighbor
					// and calculate the next g score
					ng = node.g + ((x - node.x === 0 || y - node.y === 0) ? 1 : SQRT2);
					
					// check if the neighbor has not been inspected yet, or
					// can be reached with smaller cost from the current node
					if (!neighbor.opened || ng < neighbor.g)
					{
						neighbor.g = ng;
						neighbor.h = neighbor.h || weight * heuristic(abs(x - endX), abs(y - endY));
						neighbor.f = neighbor.g + neighbor.h;
						neighbor.parent = node;
						
						if (!neighbor.opened)
						{
							openList.push(neighbor);
							neighbor.opened = true;
						}
						else
						{
							// the neighbor can be reached with smaller cost.
							// Since its f value has been updated, we have to
							// update its position in the open list
							openList.updateItem(neighbor);
						}
					}
				} // end for each neighbor
			} // end while not open list empty
			
			// fail to find the path
			return [];
		}
	}

}