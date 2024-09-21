import 'dart:collection';
import 'dart:math';

import 'package:testscript/tools.dart';

class Node {
  int index;
  int x, y;
  int g = 0, h = 0, f = 0;
  Node? parent;

  Node(this.index, this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Node && runtimeType == other.runtimeType && index == other.index;

  @override
  int get hashCode => index.hashCode;
}

Future<List<int>> findBestPathAmongstBoth(
    int numRows,
    int numCols,
    List<int> nonWalkableCells,
    int sourceIndex,
    int destinationIndex,
    int floor,
    String Bid) async {
  int sourceX = sourceIndex % numCols;
  int sourceY = sourceIndex ~/ numCols;
  int destinationX = destinationIndex % numCols;
  int destinationY = destinationIndex ~/ numCols;

  // List<int> p1 = findPath(
  //     numRows, numCols, nonWalkableCells, sourceIndex, destinationIndex);
  // p1 = await getFinalOptimizedPath(p1, nonWalkableCells, numCols, sourceX, sourceY,
  //     destinationX, destinationY, building, floor,Bid);
  // List<int> p2 = findPath(
  //     numRows, numCols, nonWalkableCells, destinationIndex, sourceIndex);
  // p2 = await getFinalOptimizedPath(p2, nonWalkableCells, numCols, destinationX,
  //     destinationY, sourceX, sourceY, building, floor,Bid);

  List<int> p1 = findPath(
      numRows, numCols, nonWalkableCells, sourceIndex, destinationIndex);
  p1 = getFinalOptimizedPath(p1, nonWalkableCells, numCols, sourceX, sourceY,
      destinationX, destinationY);
  List<int> p2 = findPath(
      numRows, numCols, nonWalkableCells, destinationIndex, sourceIndex);
  p2 = getFinalOptimizedPath(p2, nonWalkableCells, numCols, destinationX,
      destinationY, sourceX, sourceY);

  Map<int, int> p1turns = tools.getTurnMap(p1, numCols);
  Map<int, int> p2turns = tools.getTurnMap(p2, numCols);



// If either path is empty, return the other path
  if (p1.isEmpty) {
    return p2.reversed.toList();
  } else if (p2.isEmpty) {
    return p1;
  }

  // Check if both paths start and end at the correct indices
  bool p1Valid = p1.first == sourceIndex && p1.last == destinationIndex;
  bool p2Valid = p2.first == destinationIndex && p2.last == sourceIndex;

  if (p1Valid && !p2Valid) {
    return p1;
  } else if (!p1Valid && p2Valid) {
    return p2.reversed.toList();
  }

  // Compare the number of turns
  if (p1turns.length < p2turns.length) {
    return p1;
  } else if (p1turns.length > p2turns.length) {
    return p2.reversed.toList();
  }

  // If the number of turns is the same, compare the length of the paths
  if (p1.length < p2.length) {
    return p1;
  } else if (p1.length > p2.length) {
    return p2.reversed.toList();
  } else {
    return p1;
  }

  // If all else fails, return an empty list
  return [];
}

List<int> findPath(
    int numRows,
    int numCols,
    List<int> nonWalkableCells,
    int sourceIndex,
    int destinationIndex,
    ) {
  sourceIndex -= 1;
  destinationIndex -= 1;

  if (sourceIndex < 0 ||
      sourceIndex >= numRows * numCols ||
      destinationIndex < 0 ||
      destinationIndex >= numRows * numCols) {
    return [];
  }

  List<Node> nodes = List.generate(numRows * numCols, (index) {
    int x = index % numCols + 1;
    int y = index ~/ numCols + 1;
    return Node(index + 1, x, y);
  });

  Set<int> nonWalkableSet = nonWalkableCells.toSet();
  List<int> openSet = [sourceIndex];
  Set<int> closedSet = {};

  while (openSet.isNotEmpty) {
    int currentIdx = openSet.removeAt(0);
    closedSet.add(currentIdx);

    if (currentIdx == destinationIndex) {
      List<int> path = [];
      Node current = nodes[currentIdx];
      while (current.parent != null) {
        path.insert(0, current.index);
        current = current.parent!;
      }
      path.insert(0, sourceIndex + 1);
      return path;
    }

    for (int neighborIndex
    in getNeighbors(currentIdx, numRows, numCols, nonWalkableSet)) {
      if (closedSet.contains(neighborIndex)) continue;

      Node neighbor = nodes[neighborIndex];
      int tentativeG =
          nodes[currentIdx].g + getMovementCost(nodes[currentIdx], neighbor);

      if (!openSet.contains(neighborIndex) || tentativeG < neighbor.g) {
        neighbor.parent = nodes[currentIdx];
        neighbor.g = tentativeG;
        neighbor.h = heuristic(neighbor, nodes[destinationIndex]);
        neighbor.f = neighbor.g + neighbor.h;

        if (!openSet.contains(neighborIndex)) {
          openSet.add(neighborIndex);
          openSet.sort((a, b) {
            int compare = nodes[a].f.compareTo(nodes[b].f);
            if (compare == 0) {
              return nodes[a].h.compareTo(nodes[b].h);
            }
            return compare;
          });
        }
      }
    }
  }

  return [];
}

// Function to skip points between consecutive turns in the path
List<int> skipConsecutiveTurns(
    List<int> path, int numRows, int numCols, Set<int> nonWalkableSet) {
  List<int> optimizedPath = [];
  optimizedPath.add(path.first);

  for (int i = 1; i < path.length - 1; i++) {
    int prev = path[i - 1];
    int current = path[i];
    int next = path[i + 1];

    // Check if the points form a turn
    if (!isTurn(prev, current, next, numRows, numCols) ||
        nonWalkableSet.contains(current)) {
      optimizedPath.add(current);
    }
  }

  optimizedPath.add(path.last);
  return optimizedPath;
}

// Function to check if the given points form a turn
bool isTurn(int prev, int current, int next, int numRows, int numCols) {
  int prevRow = prev ~/ numCols;
  int prevCol = prev % numCols;
  int currentRow = current ~/ numCols;
  int currentCol = current % numCols;
  int nextRow = next ~/ numCols;
  int nextCol = next % numCols;

  // Check if the points form a turn
  return (prevRow == currentRow && nextCol == currentCol) ||
      (prevCol == currentCol && nextRow == currentRow);
}

List<int> getNeighbors(
    int index, int numRows, int numCols, Set<int> nonWalkableSet) {
  int x = (index % numCols) + 1;
  int y = (index ~/ numCols) + 1;
  List<int> neighbors = [];

  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) {
        continue;
      }

      int newX = x + dx;
      int newY = y + dy;

      if (newX >= 1 && newX <= numCols && newY >= 1 && newY <= numRows) {
        int neighborIndex = (newY - 1) * numCols + (newX - 1);
        if (!nonWalkableSet.contains(neighborIndex + 1)) {
          neighbors.add(neighborIndex);
        }
      }
    }
  }

  return neighbors;
}

int heuristic(Node a, Node b) {
  double dx = (a.x - b.x).toDouble();
  double dy = (a.y - b.y).toDouble();
  return sqrt(dx * dx + dy * dy).round();
}

int getMovementCost(Node a, Node b) {
  return (a.x != b.x && a.y != b.y) ? 15 : 10;
}

List<Node> getTurnpoints(List<Node> pathNodes, int numCols) {
  List<Node> res = [];

  for (int i = 1; i < pathNodes.length - 1; i++) {
    Node currPos = pathNodes[i];
    Node nextPos = pathNodes[i + 1];
    Node prevPos = pathNodes[i - 1];

    int x1 = (currPos.index % numCols);
    int y1 = (currPos.index ~/ numCols);

    int x2 = (nextPos.index % numCols);
    int y2 = (nextPos.index ~/ numCols);

    int x3 = (prevPos.index % numCols);
    int y3 = (prevPos.index ~/ numCols);

    int prevDeltaX = x1 - x3;
    int prevDeltaY = y1 - y3;
    int nextDeltaX = x2 - x1;
    int nextDeltaY = y2 - y1;

    if ((prevDeltaX != nextDeltaX) || (prevDeltaY != nextDeltaY)) {
      res.add(currPos);
    }
  }
  return res;
}

double pointLineDistance(Node point, Node start, Node end) {
  if (start.x == end.x && start.y == end.y) {
    return distance(point, start);
  } else {
    double n = ((end.x - start.x) * (start.y - point.y) -
        (start.x - point.x) * (end.y - start.y))
        .abs() +
        0.0;
    double d = sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2));
    return n / d;
  }
}

double distance(Node a, Node b) {
  return sqrt(pow(a.y - b.x, 2) + pow(a.y - b.x, 2));
}

List<Node> rdp(List<Node> points, double epsilon, Set<int> nonWalkableIndices) {
  if (points.length < 3) return points;

  // Find the point with the maximum distance
  double dmax = 0;
  int index = 0;
  int end = points.length - 1;
  for (int i = 1; i < end; i++) {
    double d = perpendicularDistance(points[i], points[0], points[end]);
    if (d > dmax) {
      index = i;
      dmax = d;
    }
  }

  // If max distance is greater than epsilon, recursively simplify
  List<Node> result = [];
  if (dmax > epsilon) {
    List<Node> recursiveResults1 =
    rdp(points.sublist(0, index + 1), epsilon, nonWalkableIndices);
    List<Node> recursiveResults2 =
    rdp(points.sublist(index, end + 1), epsilon, nonWalkableIndices);
    result = [
      ...recursiveResults1.sublist(0, recursiveResults1.length - 1),
      ...recursiveResults2
    ];
  } else {
    // Ensure rectilinear path by including only points that align with the grid
    result = [points[0]]; // Start node is always included
    Node previousPoint = points[0];
    for (int i = 1; i < end; i++) {
      if (points[i].x == previousPoint.x || points[i].y == previousPoint.y) {
        if (!nonWalkableIndices.contains(points[i].index)) {
          result.add(points[i]);
          previousPoint = points[i];
        }
      }
    }
    result.add(points[end]); // End node is always included
  }

  return result;
}

List<int> getIntersectionPoints(int currX, int currY, int prevX, int prevY,
    int nextX, int nextY, int nextNextX, int nextNextY) {
  double x1 = currX + 0.0, y1 = currY + 0.0;
  double x2 = prevX + 0.0, y2 = prevY + 0.0;
  double x3 = nextX + 0.0, y3 = nextY + 0.0;
  double x4 = nextNextX + 0.0, y4 = nextNextY + 0.0;

  double determinant = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);

  if (determinant == 0) {
    // Lines are parallel, no intersection
    return [];
  }

  double intersectionX =
      ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
          determinant;
  double intersectionY =
      ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
          determinant;

  return [intersectionX.toInt(), intersectionY.toInt()];
}

double perpendicularDistance(Node point, Node lineStart, Node lineEnd) {
  double dx = (lineEnd.x - lineStart.x) + 0.0;
  double dy = (lineEnd.y - lineStart.y) + 0.0;
  double mag = dx * dx + dy * dy;
  double u =
      ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / mag;
  double ix, iy;
  if (u < 0) {
    ix = lineStart.x.toDouble();
    iy = lineStart.y.toDouble();
  } else if (u > 1) {
    ix = lineEnd.x.toDouble();
    iy = lineEnd.y.toDouble();
  } else {
    ix = (lineStart.x + u * dx).toDouble();
    iy = (lineStart.y + u * dy).toDouble();
  }
  double dx2 = point.x - ix;
  double dy2 = point.y - iy;
  return sqrt(dx2 * dx2 + dy2 * dy2);
}

List<int> getOptiPath(Map<int, int> getTurns, int numCols, List<int> path) {
  Map<int, int> pt = {};
  var keys = getTurns.keys.toList();
  for (int i = 0; i < keys.length - 1; i++) {
    if (keys[i + 1] - 1 == keys[i]) {
      pt[keys[i + 1]] = getTurns[keys[i + 1]]!;
    }
  }

  var ptKeys = pt.keys.toList();
  for (int i = 0; i < pt.length; i++) {
    int curr = path[ptKeys[i]];
    int next = path[ptKeys[i] + 1];
    int prev = path[ptKeys[i] - 1];
    int nextNext = path[ptKeys[i] + 2];

    int currX = curr % numCols;
    int currY = curr ~/ numCols;

    int nextX = next % numCols;
    int nextY = next ~/ numCols;

    int prevX = prev % numCols;
    int prevY = prev ~/ numCols;

    int nextNextX = nextNext % numCols;
    int nextNextY = nextNext ~/ numCols;

    if (nextX == currX) {
      currY = prevY;
      int newIndexY = currY * numCols + currX;
      path[ptKeys[i]] = newIndexY;
    } else if (nextY == currY) {
      currX = prevX;
      int newIndexX = currY * numCols + currX;
      path[ptKeys[i]] = newIndexX;
    }
  }

  return path;
}

List<int> getFinalOptimizedPath(List<int> path, List<int> nonWalkableCells,
    int numCols, int sourceX, int sourceY, int destinationX, int destinationY) {
  List<List<int>> getPoints = [];
  Map<int, int> getTurns = tools.getTurnMap(path, numCols);

  path = getOptiPath(getTurns, numCols, path);

  List<int> turns = tools.getTurnpoints(path, numCols);

  for (int i = 0; i < turns.length; i++) {
    int x = turns[i] % numCols;
    int y = turns[i] ~/ numCols;

    getPoints.add([x, y]);
  }
//optimizing turnsss
  for (int i = 0; i < getPoints.length - 1; i++) {
    if (getPoints[i][0] != getPoints[i + 1][0] &&
        getPoints[i][1] != getPoints[i + 1][1]) {
      int dist =
      tools.calculateDistance(getPoints[i], getPoints[i + 1]).toInt();
      if (dist <= 15) {
        //points of prev turn
        int index1 = getPoints[i][0] + getPoints[i][1] * numCols;
        int ind1 = path.indexOf(index1);

        int prev = path[ind1 - 1];

        int currX = index1 % numCols;
        int currY = index1 ~/ numCols;

        int prevX = prev % numCols;
        int prevY = prev ~/ numCols;

        //straight line eqautaion1
        //y-prevY=(currY-prevY)/(currX-prevX)*(x-prevX);

        //points of next turn;
        int index2 = getPoints[i + 1][0] + getPoints[i + 1][1] * numCols;
        int ind2 = path.indexOf(index2);
        int next = path[ind2 + 1];

        int nextX = index2 % numCols;
        int nextY = index2 ~/ numCols;

        int nextNextX = next % numCols;
        int nextNextY = next ~/ numCols;

        int ind3 = path.indexOf(index1 - 1);

        List<int> intersectPoints = getIntersectionPoints(
            currX, currY, prevX, prevY, nextX, nextY, nextNextX, nextNextY);

        if (intersectPoints.isNotEmpty) {
          //non walkabkle check

          //first along the x plane

          //intersecting points
          int x1 = intersectPoints[0];
          int y1 = intersectPoints[1];

          //next point
          int x2 = nextX;
          int y2 = nextY;

          bool isNonWalkablePoint = false;

          while (x1 <= x2) {
            int pointIndex = x1 + y1 * numCols;
            if (nonWalkableCells.contains(pointIndex)) {
              isNonWalkablePoint = true;
              break;
            }
            x1 = x1 + 1;
          }

          //along the y-axis

          //next point
          int x3 = currX;
          int y3 = currY;

          while (y1 >= y3) {
            int pointIndex = x3 + y1 * numCols;
            if (nonWalkableCells.contains(pointIndex)) {
              isNonWalkablePoint = true;
              break;
            }
            y1 = y1 - 1;
          }

          if (isNonWalkablePoint == false) {
            path.removeRange(ind1, ind2);

            int newIndex = intersectPoints[0] + intersectPoints[1] * numCols;

            path[ind1] = newIndex;

            getPoints[i] = [intersectPoints[0], intersectPoints[1]];

            getPoints.removeAt(i + 1);
          }
        }
      }
    }
  }
  List<int> tu = [];
  tu.add(sourceX + sourceY * numCols);
  tu.addAll(tools.getTurnpoints(path, numCols));
  tu.add(destinationX + destinationY * numCols);

  //creating a new array and gearting the path from it.
  //  path.clear();
  // //
  path = tools.generateCompletePath(tu, numCols, nonWalkableCells);

  return path;
}

List<List<int>> findIntersection(List<int> p1, List<int> p2, List<int> p3,
    List<int> p11, List<int> p22, List<int> nonWalkableCells, int numCols) {
  double m1 = (p11[1] - p1[1]) / (p11[0] - p1[0]);
  double m2 = (p22[1] - p2[1]) / (p22[0] - p2[0]);
  if (m1.isInfinite || m1.isNaN) {
    m1 = p1[0] + 0.0;
  }
  if (m2.isInfinite || m2.isNaN) {
    m2 = p2[0] + 0.0;
  }
  //eq of parallel lines
  double node1 = (m1);
  double node2 = (m2);

  //checking vertical and horizontal condition

  List<List<int>> intersections = [
    [node1.toInt(), p3[1]],
    [node2.toInt(), p3[1]]
  ];

  int index1 = intersections[0][0] + intersections[0][1] * numCols;
  int index2 = intersections[1][0] + intersections[1][1] * numCols;
  if (nonWalkableCells.contains(index1) || nonWalkableCells.contains(index2)) {
    node1 = p1[1] + 0.0;
    node2 = p2[1] + 0.0;
    intersections = [
      [p3[0], node1.toInt()],
      [p3[0], node2.toInt()],
      [p1[0], p1[1]],
      [p2[0], p2[1]]
    ];
  } else {
    intersections = [
      [node1.toInt(), p3[1]],
      [node2.toInt(), p3[1]],
      [p1[0], p1[1]],
      [p2[0], p2[1]]
    ];
  }
  //noww new points areeee

  return intersections;
}

class Graph {
  Map<String, List<dynamic>> adjList;

  Graph(this.adjList);

  void addEdge(String start, String end) {
    if (adjList[start] == null) {
      adjList[start] = [];
    }
    adjList[start]!.add(end);
  }

  List<List<int>> pathfind(String start,String goal){
    Queue<String> queue = Queue();
    Map<String, String?> cameFrom = {};

    queue.add(start);
    cameFrom[start] = null;

    while (queue.isNotEmpty) {
      var current = queue.removeFirst();

      if (current == goal) {
        break;
      }

      for (var neighbor in adjList[current] ?? []) {
        if (!cameFrom.containsKey(neighbor)) {
          queue.add(neighbor);
          cameFrom[neighbor] = current;
        }
      }
    }
    List<List<int>> temppath = addCoordinatesBetweenVertices(reconstructPath(cameFrom, start, goal));

    return temppath;
  }



  Future<Map<String,dynamic>> bfs(int sourceX, int sourceY, int destinationX, int destinationY, Map<String, List<dynamic>> pathNetwork, int numRows,
      int numCols,
      List<int> nonWalkableCells)async{

    List<String> findNearestAndSecondNearestVertices(
        Map<String, List<dynamic>> pathNetwork,
        List<int> coord1,
        List<int> coord2) {
      String nearestToCoord1 = '';
      String secondNearestToCoord1 = '';
      String nearestToCoord2 = '';
      String secondNearestToCoord2 = '';
      double minDistToCoord1 = double.infinity;
      double secondMinDistToCoord1 = double.infinity;
      double minDistToCoord2 = double.infinity;
      double secondMinDistToCoord2 = double.infinity;

      // Iterate through each vertex in the pathNetwork
      pathNetwork.forEach((vertex, neighbors) {
        List<int> v = vertex.split(',').map((e) => int.parse(e)).toList();

        // Calculate distances from coord1 and coord2 to vertex v
        double distToCoord1 = sqrt(pow(v[0] - coord1[0], 2) + pow(v[1] - coord1[1], 2));
        double distToCoord2 = sqrt(pow(v[0] - coord2[0], 2) + pow(v[1] - coord2[1], 2));

        // Update nearest and second nearest vertices for coord1
        if (distToCoord1 < minDistToCoord1) {
          secondMinDistToCoord1 = minDistToCoord1;
          secondNearestToCoord1 = nearestToCoord1;
          minDistToCoord1 = distToCoord1;
          nearestToCoord1 = vertex;
        } else if (distToCoord1 < secondMinDistToCoord1) {
          secondMinDistToCoord1 = distToCoord1;
          secondNearestToCoord1 = vertex;
        }

        // Update nearest and second nearest vertices for coord2
        if (distToCoord2 < minDistToCoord2) {
          secondMinDistToCoord2 = minDistToCoord2;
          secondNearestToCoord2 = nearestToCoord2;
          minDistToCoord2 = distToCoord2;
          nearestToCoord2 = vertex;
        } else if (distToCoord2 < secondMinDistToCoord2) {
          secondMinDistToCoord2 = distToCoord2;
          secondNearestToCoord2 = vertex;
        }
      });

      if(nearestToCoord1 == "${coord1[0]},${coord1[1]}"){
        secondNearestToCoord1 = nearestToCoord1;
      }
      if(nearestToCoord2 == "${coord2[0]},${coord2[1]}"){
        secondNearestToCoord2 = nearestToCoord2;
      }
      return [
        nearestToCoord1,
        secondNearestToCoord1,
        nearestToCoord2,
        secondNearestToCoord2
      ];
    }
    List<int> tpath = [];
    List<String> states = findNearestAndSecondNearestVertices(pathNetwork, [sourceX,sourceY], [destinationX,destinationY]);
    List<int> ws = states[0].split(',').map(int.parse).toList();
    List<int> we = states[1].split(',').map(int.parse).toList();

    String start1 = states[0];
    String start2 = states[1];
    String goal1 = states[2];
    String goal2 = states[3];


    List<List<int>> temppath1 = pathfind(start1, goal1);
    List<List<int>> temppath2 = pathfind(start2, goal2);

    List<List<int>> temppath =[];
    if(temppath1.length>temppath2.length){
      temppath = temppath2;
    }else{
      temppath = temppath1;
    }

    if(tools.calculateDistance(temppath.first, [sourceX,sourceY])==1){
      temppath.insert(0, [sourceX,sourceY]);
    }
    int s = 0;
    int e = temppath.length -1;
    double d1 = 10000000;
    double d2 = 10000000;

    for(int i = 0 ; i< temppath.length ; i++){
      if(tools.calculateDistance(temppath[i], [sourceX,sourceY])<d1){
        d1 = tools.calculateDistance(temppath[i], [sourceX,sourceY]);
        s = i;
      }
      if(tools.calculateDistance(temppath[i], [destinationX,destinationY])<d2){
        d2 = tools.calculateDistance(temppath[i], [destinationX,destinationY]);
        e = i;
      }
    }
    List<int>l1 = [];
    List<int>l2 = [];
    List<int>l3 = [];
    if((sourceY*numCols)+sourceX != (temppath[s][1]*numCols)+temppath[s][0]){
      l1 = findPath(numRows, numCols, nonWalkableCells, ((sourceY*numCols) + sourceX), ((temppath[s][1]*numCols)+temppath[s][0]));
    }
    for(int i = s ; i<=e; i++){
      l2.add((temppath[i][1]*numCols) + temppath[i][0]);
    }
    if((temppath[e][1]*numCols)+temppath[e][0] != (destinationY*numCols)+destinationX){

      l3 =  findPath(numRows, numCols, nonWalkableCells, ((temppath[e][1]*numCols)+temppath[e][0]), ((destinationY*numCols) + destinationX));


    }

    if(l1.isNotEmpty || l3.isNotEmpty){
      return {"l1":l1.isNotEmpty,"l2":l2.isNotEmpty,"l3":l3.isNotEmpty,"path":getFinalOptimizedPath(mergeLists(l1, l2, l3), nonWalkableCells, numCols, sourceX, sourceY, destinationX, destinationY)};
    }else{
      return {"l1":l1.isNotEmpty,"l2":l2.isNotEmpty,"l3":l3.isNotEmpty,"path":mergeLists(l1, l2, l3)};
    }
  }

  List<int> mergeLists(List<int> l1, List<int> l2, List<int> l3) {
    List<int> result = [];

    // Helper function to find the first intersection
    int findFirstIntersection(List<int> list1, List<int> list2) {
      for (int element in list1) {
        if (list2.contains(element)) {
          return element;
        }
      }
      return -1;
    }

    if (l1.isEmpty) {
      // If l1 is empty, merge l2 and l3
      int intersectionL2L3 = findFirstIntersection(l2, l3);

      if (intersectionL2L3 == -1) {
        // No intersection, just add all elements of l2 and l3
        result.addAll(l2);
        result.addAll(l3);
      } else {
        // Add elements of l2 till the intersection
        for (int i = 0; i < l2.length && l2[i] != intersectionL2L3; i++) {
          result.add(l2[i]);
        }
        result.add(intersectionL2L3);

        // Add elements of l3 after the intersection till the end
        int indexL2L3 = l3.indexOf(intersectionL2L3);
        for (int i = indexL2L3 + 1; i < l3.length; i++) {
          result.add(l3[i]);
        }
      }

    } else if (l3.isEmpty) {
      // If l3 is empty, merge l1 and l2
      int intersectionL1L2 = findFirstIntersection(l1, l2);

      if (intersectionL1L2 == -1) {
        // No intersection, just add all elements of l1 and l2
        result.addAll(l1);
        result.addAll(l2);
      } else {
        // Add elements of l1 till the intersection
        for (int i = 0; i < l1.length && l1[i] != intersectionL1L2; i++) {
          result.add(l1[i]);
        }
        result.add(intersectionL1L2);

        // Add elements of l2 after the intersection till the end
        int indexL1L2 = l2.indexOf(intersectionL1L2);
        for (int i = indexL1L2 + 1; i < l2.length; i++) {
          result.add(l2[i]);
        }
      }

    } else {
      // If neither l1 nor l3 is empty, perform the original merging logic
      int intersectionL1L2 = findFirstIntersection(l1, l2);

      if (intersectionL1L2 == -1) return result;

      // Add elements of l1 till the intersection
      for (int i = 0; i < l1.length && l1[i] != intersectionL1L2; i++) {
        result.add(l1[i]);
      }
      result.add(intersectionL1L2);

      // Find the first intersection of l2 and l3 after the intersection with l1
      int intersectionL2L3 = findFirstIntersection(l2.sublist(l2.indexOf(intersectionL1L2) + 1), l3);

      if (intersectionL2L3 == -1) return result;

      // Add elements of l2 after the first intersection till the next intersection
      int indexL1L2 = l2.indexOf(intersectionL1L2);
      for (int i = indexL1L2 + 1; i < l2.length && l2[i] != intersectionL2L3; i++) {
        result.add(l2[i]);
      }
      result.add(intersectionL2L3);

      // Add elements of l3 after the intersection till the end
      int indexL2L3 = l3.indexOf(intersectionL2L3);
      for (int i = indexL2L3 + 1; i < l3.length; i++) {
        result.add(l3[i]);
      }
    }

    return result;
  }



  List<List<int>> reconstructPath(Map<String, String?> cameFrom, String start, String goal) {
    List<List<int>> path = [];

    if (!cameFrom.containsKey(goal)) {
      return path; // no path found
    }

    for (String? at = goal; at != null; at = cameFrom[at]) {
      var coordinates = at.split(',').map((coord) => int.parse(coord)).toList();
      path.add(coordinates);
    }
    path = path.reversed.toList();

    if (path[0].join(',') == start) {
      return path;
    }
    return []; // no path found
  }

  List<int> toindex (List<List<int>> path,int numcols){
    List<int> indexpath = [];
    path.forEach((element) {
      indexpath.add((element[1]*numcols )+ element[0]);
    });
    return indexpath;
  }

  List<List<int>> addCoordinatesBetweenVertices(List<List<int>> coordinates) {
    var newCoordinates = <List<int>>[];

    for (var i = 0; i < coordinates.length - 1; i++) {
      var startX = coordinates[i][0];
      var startY = coordinates[i][1];
      var endX = coordinates[i + 1][0];
      var endY = coordinates[i + 1][1];

      // Determine the direction of increment for x and y
      var signX = startX < endX ? 1 : -1;
      var signY = startY < endY ? 1 : -1;

      // Add the starting point
      if(newCoordinates.isNotEmpty && newCoordinates.last[0] != startX && newCoordinates.last[1] != startY){
        newCoordinates.add([startX, startY]);
      }

      // Add intermediate points
      var x = startX;
      var y = startY;
      while (x != endX || y != endY) {
        if (x != endX) {
          x += signX;
        }
        if (y != endY) {
          y += signY;
        }
        newCoordinates.add([x, y]);
      }
    }

    // Add the last coordinate
    newCoordinates.add([coordinates.last[0], coordinates.last[1]]);

    return newCoordinates;
  }


}