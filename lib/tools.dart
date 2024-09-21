import 'dart:math';

class tools {
  static Map<int, int> getTurnMap(List<int> pathNodes, int numCols) {
    Map<int, int> res = new Map();

    for (int i = 1; i < pathNodes.length - 1; i++) {
      int currPos = pathNodes[i];
      int nextPos = pathNodes[i + 1];
      int prevPos = pathNodes[i - 1];

      int x1 = (currPos % numCols);
      int y1 = (currPos ~/ numCols);

      int x2 = (nextPos % numCols);
      int y2 = (nextPos ~/ numCols);

      int x3 = (prevPos % numCols);
      int y3 = (prevPos ~/ numCols);

      int prevDeltaX = x1 - x3;
      int prevDeltaY = y1 - y3;
      int nextDeltaX = x2 - x1;
      int nextDeltaY = y2 - y1;

      if ((prevDeltaX != nextDeltaX) || (prevDeltaY != nextDeltaY)) {
        if (prevDeltaX == 0 && nextDeltaX == 0) {
        } else if (prevDeltaY == 0 && nextDeltaY == 0) {
        } else {
          res[i] = currPos;
        }
      }
    }
    return res;
  }

  static List<int> getTurnpoints(List<int> pathNodes, int numCols) {
    List<int> res = [];

    for (int i = 1; i < pathNodes.length - 1; i++) {
      int currPos = pathNodes[i];
      int nextPos = pathNodes[i + 1];
      int prevPos = pathNodes[i - 1];

      int x1 = (currPos % numCols);
      int y1 = (currPos ~/ numCols);

      int x2 = (nextPos % numCols);
      int y2 = (nextPos ~/ numCols);

      int x3 = (prevPos % numCols);
      int y3 = (prevPos ~/ numCols);

      int prevDeltaX = x1 - x3;
      int prevDeltaY = y1 - y3;
      int nextDeltaX = x2 - x1;
      int nextDeltaY = y2 - y1;

      if ((prevDeltaX != nextDeltaX) || (prevDeltaY != nextDeltaY)) {
        if (prevDeltaX == 0 && nextDeltaX == 0) {
        } else if (prevDeltaY == 0 && nextDeltaY == 0) {
        } else {
          res.add(currPos);
        }
      }
    }
    return res;
  }

  static double calculateDistance(List<int> p1, List<int> p2) {
    return sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2));
  }

  static List<int> generateCompletePath(
      List<int> turns, int numCols, List<int> nonWalkableCells) {
    List<int> completePath = [];

    // Start with the first point in your path
    int currentPoint = turns[0];
    int x = currentPoint % numCols;
    int y = currentPoint ~/ numCols;
    completePath.add(x + y * numCols);

    // Connect each turn point with a straight line
    for (int i = 1; i < turns.length; i++) {
      int turnPoint = turns[i];
      int turnX = turnPoint % numCols;
      int turnY = turnPoint ~/ numCols;

      // Connect straight line from current point to turn point
      while (x != turnX || y != turnY) {
        if (x < turnX) {
          x++;
        } else if (x > turnX) {
          x--;
        }
        if (y < turnY) {
          y++;
        } else if (y > turnY) {
          y--;
        }

        // Convert current x, y coordinates back to index form
        int currentIndex = x + y * numCols;

        // Check if the current index is in the non-walkable cells list
        if (nonWalkableCells.contains(currentIndex)) {
          // Handle non-walkable cell, such as breaking out of the loop or finding an alternative path
          // Here, I'll just break out of the loop
          break;
        }

        // Add the current index to the complete path
        completePath.add(currentIndex);
      }
    }

    return completePath;
  }


// Function to check if a point (x, y) is within range of P1 or P2
  static bool isWithinRange(List<int> target, List<int> p1, List<int> p2, double range) {
    double distanceToP1 = calculateDistance(target, p1);
    double distanceToP2 = calculateDistance(target, p2);
    return distanceToP1 <= range && distanceToP2 <= range;
  }

  static int calculateindex(int x, int y, int fl) {
    return (y * fl) + x;
  }

  static int sumUsingLoop(int n) {
    int sum = 0;
    for (int i = 1; i <= n; i++) {
      sum += i;
    }
    return sum;
  }
}