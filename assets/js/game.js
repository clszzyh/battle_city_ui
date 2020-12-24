import * as CONSTANT from "./constant";
import { toggle_simulate_latency, toggle_debug } from "./live_socket";

const draw_entity = (o, that) => {
  let width;
  let height;
  let rect;
  switch (o.type) {
    case "t":
      rect = CONSTANT.TANK_IMAGE[o.kind][o.d];
      width = 2 * CONSTANT.TANK_RADIUS;
      height = 2 * CONSTANT.TANK_RADIUS;
      break;
    case "b":
      rect = CONSTANT.BULLET_IMAGE[o.d];
      width = 2 * CONSTANT.BULLET_RADIUS;
      height = 2 * CONSTANT.BULLET_RADIUS;
      break;
    case "e":
      rect = CONSTANT.BUILDING_IMAGE[o.kind];
      width = 2 * CONSTANT.BUILDING_RADIUS;
      height = 2 * CONSTANT.BUILDING_RADIUS;
      break;
    default:
      console.log(o);
  }

  if (rect) {
    that.context.drawImage(
      that.sprites,
      rect[0],
      rect[1],
      rect[2],
      rect[3],
      o.x - width / 2,
      o.y - height / 2,
      width,
      height
    );
  }
};

const draw = (data, that) => {
  that.context.clearRect(
    0,
    0,
    that.context.canvas.width,
    that.context.canvas.height
  );
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
      .concat(JSON.parse(this.el.dataset.bullet_grids));
  },
  mounted() {
    let canvas = this.el.querySelector("#canvas");
    let sprites = this.el.querySelector("#sprites");
    let context = canvas.getContext("2d");
    context.canvas.width = window.innerWidth;
    context.canvas.height = window.innerHeight;

    Object.assign(this, {
      canvas,
      context,
      sprites,
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
