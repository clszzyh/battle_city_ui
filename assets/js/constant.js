export const GRID_COUNT = 26;

export const TANK_IMAGE = {
  level1: {
    up: [0, 0],
    down: [264, 0],
    left: [136, 0],
    right: [392, 0],
  },
  basic: {
    up: [524, 264],
    down: [780, 264],
    left: [648, 272],
    right: [908, 268],
  },
  fast: {
    up: [524, 328],
    down: [780, 332],
    left: [648, 336],
    right: [908, 332],
  },
  power: {
    up: [524, 396],
    down: [780, 396],
    left: [648, 404],
    right: [908, 400],
  },
  armor: {
    up: [524, 460],
    down: [780, 460],
    left: [648, 464],
    right: [904, 464],
  },
};

export const BULLET_IMAGE = {
  up: [1320, 408, 12, 16],
  down: [1384, 408, 12, 16],
  left: [1348, 408, 16, 12],
  right: [1412, 408, 16, 12],
};

export const BUILDING_IMAGE = {
  steel_wall: {
    full: [1052, 0],
    bottom: [1180, 0],
    top: [1308, 0],
    left: [1244, 0],
    right: [1116, 0],
    right_bottom: [1116, 0, 64, 32, 1, 0.5, 0, 8],
    left_bottom: [1244, 0, 64, 32, 1, 0.5, 0, 8],
  },
  brick_wall: {
    full: [1052, 64],
    bottom: [1180, 64],
    top: [1308, 64],
    left: [1244, 64],
    right: [1116, 64],
  },
  tree: { full: [1116, 128] },
  water: { full: [1052, 192] },
  home: {
    full: [1244, 128],
    dead: [1244, 128],
  },
  ice: { full: [1180, 128] },
  blank: { full: [1116, 800] },
};
