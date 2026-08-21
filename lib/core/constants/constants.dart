class GameConstants {
  static const double worldWidth = 3840;
  static const double worldHeight = 3840;

  static const double birdWalkSpeed = 300.0;
  static const double birdRunSpeed = 200.0;
  static const double birdFlySpeed = 300.0;

  static const double minHappiness = 0.0;
  static const double maxHappiness = 100.0;

  static const double minHunger = 0.0;
  static const double maxHunger = 100.0;

  static const double minEnergy = 0.0;
  static const double maxEnergy = 100.0;

  static const double minCleanliness = 0.0;
  static const double maxCleanliness = 100.0;

  static const double pondX = 1920.0;
  static const double pondY = 1920.0;
  static const double pondRadius = 400.0;

  static const String birdNameKey = 'bird_name';
  static const String birdProfileKey = 'bird_profile';
  static const String backgroundKey = 'game_background';

  static const double pondWidth = 800;
  static const double pondHeight = 600;

  // New Locations
  static const double feedingX = 400.0;
  static const double feedingY = 400.0;
  static const double feedingSize = 250.0;

  static const double playX = 1600.0;
  static const double playY = 1600.0;
  static const double playSize = 300.0;

  static const double sleepX = 1600.0;
  static const double sleepY = 400.0;
  static const double sleepSize = 250.0;

  // Trees
  static const int treeCount = 18;
  static const double treeSize = 150;
  static const double treePadding = 80;
  static const double treeSpacing = 110;

  // Camera Zoom
  static const double initialZoom = 0.5;
  static const double maxZoom = 2.0;

  // Life Cycle (Real-time simulation)
  // How many real-world seconds represent a full 24-hour cycle in game.
  // Default: 600 seconds (10 minutes) = 1 Game Day.
  static const double fullCycleSeconds = 600.0; 

  // Ground Constraints (To keep bird out of sky and corners)
  static const double groundTopY = worldHeight * 0.33; // Top 1/3 is sky
  static const double groundBottomY = worldHeight * 0.95; // Small padding at bottom
  static const double groundSidePadding = 150.0; // Avoid corner trees/bushes

  static const List<Map<String, String>> backgrounds = [
    {
      'name': 'Day',
      'path': 'environment/background/day.png',
      'asset': 'assets/images/environment/background/day.png',
    },
    {
      'name': 'Park',
      'path': 'environment/background/park.png',
      'asset': 'assets/images/environment/background/park.png',
    },
    {
      'name': 'Grassland',
      'path': 'environment/background/grass_land.png',
      'asset': 'assets/images/environment/background/grass_land.png',
    },
    {
      'name': 'Outlands',
      'path': 'environment/background/out_lands.png',
      'asset': 'assets/images/environment/background/out_lands.png',
    },
  ];

  static const List<Map<String, String>> clothing = [
    {
      'name': 'None',
      'asset': '',
    },
    {
      'name': 'Red Vest',
      'asset': 'birds/walking_clothes.png',
    },
  ];
}
