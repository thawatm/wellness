class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.kacl = 0,
    this.serving = '',
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  String serving;
  List<String> meals;
  int kacl;

  static List<MealsListData> tabIconsList = <MealsListData>[
    // MealsListData(
    //   imagePath: 'assets/fitness_app/breakfast.png',
    //   titleTxt: 'Breakfast',
    //   kacl: 525,
    //   meals: <String>['Bread,', 'Peanut butter,', 'Apple'],
    //   startColor: '#FA7D82',
    //   endColor: '#FFB295',
    // ),
    // MealsListData(
    //   imagePath: 'assets/fitness_app/lunch.png',
    //   titleTxt: 'Lunch',
    //   kacl: 602,
    //   meals: <String>['Salmon,', 'Mixed veggies,', 'Avocado'],
    //   startColor: '#738AE6',
    //   endColor: '#5C5EDD',
    // ),
    // MealsListData(
    //   imagePath: 'assets/fitness_app/snack.png',
    //   titleTxt: 'Snack',
    //   kacl: 0,
    //   meals: <String>['Recommend:', '800 kcal'],
    //   startColor: '#FE95B6',
    //   endColor: '#FF5287',
    // ),
    // MealsListData(
    //   imagePath: 'assets/fitness_app/dinner.png',
    //   titleTxt: 'Dinner',
    //   kacl: 0,
    //   meals: <String>['Recommend:', '703 kcal'],
    //   startColor: '#6F72CA',
    //   endColor: '#1E1466',
    // ),
    MealsListData(
      imagePath: 'assets/fitness_app/watermelon.jpg',
      titleTxt: 'แตงโม',
      kacl: 1,
      meals: <String>['', '11.00am'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/pineapple.jpg',
      titleTxt: 'สับปะรด',
      kacl: 2,
      meals: <String>['', '11.00am'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/salad.jpg',
      titleTxt: 'สลัด',
      kacl: 1,
      meals: <String>['', '11.00am'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/fruitsalad.jpg',
      titleTxt: 'ผลไม้รวม',
      kacl: 2,
      meals: <String>['', '11.00am'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}
