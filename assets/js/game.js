import * as CONSTANT from "./constant";
import { toggle_simulate_latency, toggle_debug } from "./live_socket";

const draw_entity = (o, that) => {
  let { grid_size, context, sprites } = that;
  let rect;
  let size;
  switch (o.type) {
    case "t":
      rect = CONSTANT.TANK_IMAGE[o.kind][o.d] || console.error(o);
      size = grid_size * 2;
      break;
    case "b":
      rect = CONSTANT.BULLET_IMAGE[o.d] || console.error(o);
      size = grid_size / 3;
      break;
    case "e":
      rect = CONSTANT.BUILDING_IMAGE[o.kind][o.d] || console.error(o);
      size = grid_size * 2;
      break;
    case "p":
      rect = CONSTANT.POWERUP_IMAGE[o.kind] || console.error(o);
      size = grid_size * 2;
      break;
    default:
      console.log(o);
  }

  // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/drawImage

  if (rect) {
    context.drawImage(
      sprites,
      rect[0],
      rect[1],
      rect[2] || 64,
      rect[3] || 64,
      ((rect[6] ? rect[6] + o.x : o.x) * grid_size) / 8 +
        (grid_size - size / 2),
      ((rect[7] ? rect[7] + o.y : o.y) * grid_size) / 8 +
        (grid_size - size / 2),
      rect[4] ? size * rect[4] : size,
      rect[5] ? size * rect[5] : size
    );
  }
};

const draw = (data, that) => {
  let { context } = that;
  // let width = that.game_width();
  let width = context.canvas.width;
  let height = context.canvas.height;
  context.clearRect(0, 0, width, height);
  context.font = "20px monospace";
  context.fillStyle = "white";
  context.fillText("123", 20, 30);
  context.fillStyle = "black";
  context.fillRect(0, 0, width, height);

  data.forEach((o) => draw_entity(o, that));
};

const tick = (data, that) => {
  data = that.grids();
  let { canvas, context, sprites } = that;

  let halfHeight = canvas.height / 2;
  let halfWidth = canvas.width / 2;
  let smallerHalf = Math.min(halfHeight, halfWidth);

  that.j++;
  if (that.j % 5 === 0) {
    that.j = 0;
    let now = performance.now();
    that.ups = 1 / ((now - (that.upsNow || now)) / 5000);
    that.upsNow = now;
  }

  if (that.animationFrameRequest) {
    cancelAnimationFrame(that.animationFrameRequest);
  }

  that.animationFrameRequest = requestAnimationFrame(() => {
    that.animationFrameRequest = undefined;

    draw(data, that);

    that.i++;
    if (that.i % 5 === 0) {
      that.i = 0;
      let now = performance.now();
      that.fps = 1 / ((now - (that.fpsNow || now)) / 5000);
      that.fpsNow = now;
    }

    // context.textBaseline = "top";
    // context.font = "20pt monospace";
    // context.fillStyle = "#f0f0f0";
    // context.beginPath();
    // context.rect(0, 0, 260, 80);
    // context.fill();
    // context.fillStyle = "black";

    // context.fillText(`Client FPS: ${Math.round(that.fps)}`, 10, 10);
    // context.fillText(`Server FPS: ${Math.round(that.ups)}`, 10, 40);
  });
};

export const GameHook = {
  grids() {
    return []
      .concat(JSON.parse(this.el.dataset.map_grids))
      .concat(JSON.parse(this.el.dataset.tank_grids))
      .concat(JSON.parse(this.el.dataset.power_up_grids))
      .concat(JSON.parse(this.el.dataset.bullet_grids));
  },
  size() {
    return this.el.dataset.size;
  },
  game_width() {
    return this.size() * CONSTANT.GRID_COUNT;
  },
  mounted() {
    let canvas = this.el.querySelector("#canvas");
    let sprites = this.el.querySelector("#sprites");
    let context = canvas.getContext("2d");
    let grid_size = this.size();
    context.canvas.width = window.innerWidth;
    context.canvas.height = window.innerHeight;

    Object.assign(this, {
      canvas,
      context,
      sprites,
      grid_size,
      i: 0,
      j: 0,
      fps: 0,
      ups: 0,
    });
    this.handleEvent("toggle_debug", ({ value }) => toggle_debug(value));
    this.handleEvent("toggle_simulate_latency", ({ value }) =>
      toggle_simulate_latency(value)
    );
    this.handleEvent("tick", ({ value }) => tick(value, this));
    this.handleEvent("play_audio", ({ id }) =>
      this.el.querySelector("#" + id).play()
    );
  },
};
