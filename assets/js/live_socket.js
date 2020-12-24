export const toggle_debug = (value) => {
  console.log(`toggle_debug ${value}`);
  if (value) {
    liveSocket.enableDebug();
  } else {
    liveSocket.disableDebug();
  }
};

export const toggle_simulate_latency = (value) => {
  console.log(`toggle_simulate_latency ${value}`);
  if (value) {
    liveSocket.enableLatencySim(value);
  } else {
    liveSocket.disableLatencySim();
  }
};
