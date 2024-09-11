import 'dart:math';

class MathTestUtils {
  static final Random _rand = Random();

  static Map<String, dynamic> generateComplexQuestion() {
    int a = _rand.nextInt(900) + 100; // ensures a is between 100 and 999
    int b = _rand.nextInt(900) + 100; // ensures b is between 100 and 999
    int answer;
    String question;

    switch (_rand.nextInt(4)) {
      case 0:
      // Addition
        answer = a + b;
        question = "$a + $b = ?";
        break;
      case 1:
      // Soustraction (a should be greater than b)
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
        question = "$a - $b = ?";
        break;
      case 2:
      // Multiplication
        answer = a * b;
        question = "$a × $b = ?";
        break;
      case 3:
      default:
      // Division (ensure that b is not zero and a is a multiple of b)
        b = _rand.nextInt(98) + 2; // ensures b is between 2 and 99
        a = b * (_rand.nextInt((900 / b).toInt()) + 1); // ensures a is a multiple of b
        answer = a ~/ b; // Integer division
        question = "$a ÷ $b = ?";
        break;
    }

    return {
      'question': question,
      'answer': answer,
    };
  }

  static int calculatePoints(double correctAnswer, double userAnswer) {
    double difference = ((userAnswer - correctAnswer).abs() / correctAnswer) * 100;

    if (difference <= 1) {
      return 100;
    } else if (difference <= 5) {
      return 50;
    } else if (difference <= 10) {
      return 25;
    } else if (difference <= 20) {
      return 5;
    } else {
      return 0;
    }
  }

  static Map<String, dynamic> generateQuestion(int difficultyLevel, String mode) {
    int a, b;
    String newQuestion;
    int answer;

    List<int> rangeA, rangeB;
    List<int> rangeMulA, rangeMulB;
    List<int> rangeDivA, rangeDivB;

    switch (difficultyLevel) {
      case 1:
        rangeA = [0, 10];
        rangeB = [0, 10];
        rangeMulA = [0, 10];
        rangeMulB = [0, 1, 2, 5, 10];
        rangeDivA = [0, 100];
        rangeDivB = [1, 2, 5, 10];
        break;
      case 2:
        rangeA = [11, 20];
        rangeB = [1, 10];
        rangeMulA = [2, 10];
        rangeMulB = [3, 4, 8];
        rangeDivA = [0, 100];
        rangeDivB = [3, 4, 8];
        break;
      case 3:
        rangeA = [21, 30];
        rangeB = [11, 20];
        rangeMulA = [3, 10];
        rangeMulB = [7, 9];
        rangeDivA = [0, 100];
        rangeDivB = [7, 9];
        break;
      case 4:
        rangeA = [31, 39];
        rangeB = [21, 29];
        rangeMulA = [3, 11];
        rangeMulB = [11];
        rangeDivA = [0, 121];
        rangeDivB = [11];
        break;
      case 5:
        rangeA = [41, 49];
        rangeB = [31, 39];
        rangeMulA = [3, 12];
        rangeMulB = [12];
        rangeDivA = [0, 144];
        rangeDivB = [12];
        break;
      case 6:
        rangeA = [59, 69];
        rangeB = [41, 49];
        rangeMulA = [3, 13];
        rangeMulB = [13];
        rangeDivA = [0, 169];
        rangeDivB = [13];
        break;
      case 7:
        rangeA = [69, 79];
        rangeB = [59, 69];
        rangeMulA = [3, 14];
        rangeMulB = [14];
        rangeDivA = [0, 196];
        rangeDivB = [14];
        break;
      case 8:
        rangeA = [79, 89];
        rangeB = [79, 89];
        rangeMulA = [3, 15];
        rangeMulB = [15];
        rangeDivA = [0, 225];
        rangeDivB = [15];
        break;
      case 9:
        rangeA = [89, 99];
        rangeB = [79, 89];
        rangeMulA = [3, 19];
        rangeMulB = [16, 19];
        rangeDivA = [225, 499];
        rangeDivB = [16, 19];
        break;
      case 10:
        rangeA = [101, 999];
        rangeB = [101, 999];
        rangeMulA = [3, 19];
        rangeMulB = [21, 99];
        rangeDivA = [499, 999];
        rangeDivB = [19, 49];
        break;
      default:
        rangeA = [0, 10];
        rangeB = [0, 10];
        rangeMulA = [0, 10];
        rangeMulB = [0, 1, 2, 5, 10];
        rangeDivA = [0, 100];
        rangeDivB = [1, 2, 5, 10];
        break;
    }

    switch (mode) {
      case 'Addition':
        a = _rand.nextInt(rangeA[1] - rangeA[0] + 1) + rangeA[0];
        b = _rand.nextInt(rangeB[1] - rangeB[0] + 1) + rangeB[0];
        answer = a + b;
        newQuestion = "$a + $b = ?";
        break;
      case 'Soustraction':
        a = _rand.nextInt(rangeA[1] - rangeA[0] + 1) + rangeA[0];
        b = _rand.nextInt(rangeB[1] - rangeB[0] + 1) + rangeB[0];
        if (a < b) {
          int temp = a;
          a = b;
          b = temp;
        }
        answer = a - b;
        newQuestion = "$a - $b = ?";
        break;
      case 'Multiplication':
        a = _rand.nextInt(rangeMulA[1] - rangeMulA[0] + 1) + rangeMulA[0];
        b = rangeMulB[_rand.nextInt(rangeMulB.length)];
        answer = a * b;
        newQuestion = "$a × $b = ?";
        break;
      case 'Division':
        do {
          b = rangeDivB[_rand.nextInt(rangeDivB.length)];
          if (difficultyLevel <= 3) {
            a = b * (_rand.nextInt(10) + 1); // Ensure the result is <= 10 for levels 1-3
          } else {
            a = b * (_rand.nextInt((rangeDivA[1] ~/ b) - (rangeDivA[0] ~/ b) + 1) + (rangeDivA[0] ~/ b));
          }
        } while (b == 0 || (difficultyLevel <= 3 && a / b > 10)); // Ensure valid division and result <= 10 for levels 1-3
        answer = a ~/ b; // Ensure integer division
        newQuestion = "$a ÷ $b = ?";
        break;
      case 'Mixte':
        List<String> modes = ['Addition', 'Soustraction', 'Multiplication', 'Division'];
        String randomMode = modes[_rand.nextInt(modes.length)];
        return generateQuestion(difficultyLevel, randomMode);
      default:
        newQuestion = "Error";
        answer = 0;
        break;
    }

    return {
      'question': newQuestion,
      'answer': answer,
    };
  }

  static void submitAnswer({
    required String userAnswer,
    required int correctAnswer,
    required List<int> responseTimes,
    required Stopwatch stopwatch,
    required List<bool> answerHistory,
    required Map<String, List<bool>> operationResults,
    required String operation,
    required int points,
    required Function onCorrect,
    required Function onIncorrect,
  }) {
    stopwatch.stop();
    int responseTime = stopwatch.elapsedMilliseconds;
    responseTimes.add(responseTime);

    if (int.tryParse(userAnswer) == correctAnswer) {
      answerHistory.add(true);
      operationResults[operation]!.add(true);
      points += 10;
      onCorrect();
    } else {
      answerHistory.add(false);
      operationResults[operation]!.add(false);
      points -= 5;
      onIncorrect();
    }
  }
}
