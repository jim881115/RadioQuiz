# Radio Quiz - Amateur Radio License Practice App (Taiwan)

This is a practice app for the **Taiwan Amateur Radio License Exam**, covering all levels 1、2 and 3. The app simulates the actual exam scenario by randomly selecting questions with the correct number of questions for each level. 

### **Features**
- **Complete Question Set**: Includes all questions for **Level 1, Level 2, and Level 3** exams.
- **Realistic Simulation**: Randomized questions that mimic the actual exam format and number of questions.
- **Review Mistakes**: After completing the quiz, you can review incorrect answers, showing the correct answers for better learning.

---

## **App Interface and Functionality**

### **Home Page**
- Choose between **Level 1, Level 2, or Level 3** for the quiz.
- Start the quiz simulation with a click on the desired level.
<div align="center">
  <img src="https://hackmd.io/_uploads/H184MAYs1g.jpg" alt="question page" width="25%" style="max-width: 25%;"/>
</div>

### **Quiz Page**
- Displays **current question number, remaining time, and a button to end the quiz**.
- Shows the **question, related image (if any), and 4 possible options**.
- Users can navigate between **previous and next questions** while selecting answers.
<div align="center">
  <img src="https://hackmd.io/_uploads/r1lwz0ts1g.jpg" alt="question page" width="25%" style="max-width: 25%;"/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://hackmd.io/_uploads/SJAIzAKskl.jpg" alt="question page with picture" width="25%" style="max-width: 25%;"/>
</div>

### **Results Page**
- Displays the **number of correct and incorrect answers** and the passing standard for the selected level.
- Lists **incorrect questions** with both the **incorrect choices and the correct answers**.
- Users can review each mistake and navigate between questions, with an option to return to the home page for further practice.
<div align="center">
  <img src="https://hackmd.io/_uploads/HJ2LfRYjkl.jpg" alt="question page" width="25%" style="max-width: 25%;"/>
</div>

---

## **Tech Stack**
- **Flutter** (Cross-platform development)
- **Dart** (Programming language used for Flutter development)
- **SQLite** (Storing questions data)

---

## **How to Run**

1. **Install Flutter** (Follow the [official guide](https://docs.flutter.dev/get-started/install)).
2. Clone the repository and navigate to the project folder:
   ```sh
   git clone https://github.com/jim881115/RadioQuiz.git
   cd RadioQuiz
   flutter pub get
   flutter run
   ```

## **Future Updates**
- Add historical test result tracking
