const toggle_debug = (value) => {
  console.log(`toggle_debug ${value}`);
  if (value) {
    liveSocket.enableDebug();
  } else {
    liveSocket.disableDebug();
  }
};

const toggle_simulate_latency = (value) => {
  console.log(`toggle_simulate_latency ${value}`);
  if (value) {
    liveSocket.enableLatencySim(value);
  } else {
    liveSocket.disableLatencySim();
  }
};

const GameHook = {
  mounted() {
    this.handleEvent("toggle_debug", ({ value }) => toggle_debug(value));
    this.handleEvent("toggle_simulate_latency", ({ value }) =>
      toggle_simulate_latency(value)
    );
  },
};
export default GameHook;
