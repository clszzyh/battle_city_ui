export const TANK_IMAGE = {
  level1: {
    up: [4, 8, 52, 52],
    down: [264, 4, 52, 52],
    left: [136, 4, 52, 52],
    right: [392, 4, 52, 52],
  },
  basic: {
    up: [524, 264, 52, 60],
    down: [780, 264, 52, 60],
    left: [648, 272, 60, 52],
    right: [908, 268, 60, 52],
  },
  fast: {
    up: [524, 328, 52, 60],
    down: [780, 332, 52, 60],
    left: [648, 336, 60, 52],
    right: [908, 332, 60, 52],
  },
  power: {
    up: [524, 396, 52, 60],
    down: [780, 396, 52, 60],
    left: [648, 404, 60, 52],
    right: [908, 400, 60, 52],
  },
  armor: {
    up: [524, 460, 52, 60],
    down: [780, 460, 52, 60],
    left: [648, 464, 60, 52],
    right: [904, 464, 60, 52],
  },
};

export const BULLET_IMAGE = {
  up: [1320, 408, 12, 16],
  down: [1384, 408, 12, 16],
  left: [1348, 408, 16, 12],
  right: [1412, 408, 16, 12],
};

export const BUILDING_IMAGE = {
  brick_wall: [1052, 64, 64, 64],
  steel_wall: [1052, 0, 64, 64],
  tree: [1116, 128, 64, 64],
  water: [1052, 192, 64, 64],
  home: [1244, 128, 64, 64],
  ice: [1180, 128, 64, 64],
  blank: [1116, 800, 64, 64],
};

export const TANK_RADIUS = 32;
export const BULLET_RADIUS = 32;
export const BUILDING_RADIUS = 32;
export const EXPLOSION_RADIUS = 16;
