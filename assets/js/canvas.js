const getPixelRatio = (context) => {
  var backingStore =
    context.backingStorePixelRatio ||
    context.webkitBackingStorePixelRatio ||
    context.mozBackingStorePixelRatio ||
    context.msBackingStorePixelRatio ||
    context.oBackingStorePixelRatio ||
    context.backingStorePixelRatio ||
    1;

  return (window.devicePixelRatio || 1) / backingStore;
};

const fade = (canvas, context, amount) => {
  context.beginPath();
  context.rect(0, 0, canvas.width, canvas.height);
  context.fillStyle = `rgba(255, 255, 255, ${amount})`;
  context.fill();
};

const resize = (canvas, ratio) => {
  canvas.width = window.innerWidth * ratio;
  canvas.height = window.innerHeight * ratio;
  canvas.style.width = `${window.innerWidth}px`;
  canvas.style.height = `${window.innerHeight}px`;
};

const cubehelix = (s, r, h) => (d) => {
  let t = 2 * Math.PI * (s / 3 + r * d);
  let a = (h * d * (1 - d)) / 2;
  return [
    d + a * (-0.14861 * Math.cos(t) + Math.sin(t) * 1.78277),
    d + a * (-0.29227 * Math.cos(t) + Math.sin(t) * -0.90649),
    d + a * (1.97294 * Math.cos(t) + Math.sin(t) * 0.0),
  ];
};

const update_particles = (data, that) => {
  let { canvas, colorizer, context, ratio } = that;
  let particles = JSON.parse(data);

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

    fade(canvas, context, 0.5);
    particles.forEach(([a, x, y]) => {
      let [r, g, b] = colorizer(a);
      context.fillStyle = `rgb(${r * 255}, ${g * 255}, ${b * 255})`;
      context.beginPath();
      context.arc(
        halfWidth + x * smallerHalf,
        halfHeight + y * smallerHalf,
        a * (smallerHalf / 16),
        0,
        2 * Math.PI
      );
      context.fill();
    });

    that.i++;
    if (that.i % 5 === 0) {
      that.i = 0;
      let now = performance.now();
      that.fps = 1 / ((now - (that.fpsNow || now)) / 5000);
      that.fpsNow = now;
    }
    context.textBaseline = "top";
    context.font = "20pt monospace";
    context.fillStyle = "#f0f0f0";
    context.beginPath();
    context.rect(0, 0, 260, 80);
    context.fill();
    context.fillStyle = "black";
    context.fillText(`Client FPS: ${Math.round(that.fps)}`, 10, 10);
    context.fillText(`Server FPS: ${Math.round(that.ups)}`, 10, 40);
  });
};

export const CanvasHook = {
  mounted() {
    let canvas = this.el.firstElementChild;
    let context = canvas.getContext("2d");
    let ratio = getPixelRatio(context);
    let colorizer = cubehelix(3, 0.5, 2.0);

    resize(canvas, ratio);

    Object.assign(this, {
      canvas,
      colorizer,
      context,
      ratio,
      i: 0,
      j: 0,
      fps: 0,
      ups: 0,
    });
    this.handleEvent("particles", ({ data }) => update_particles(data, this));
  },
};
