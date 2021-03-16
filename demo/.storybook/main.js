module.exports = {
  stories: ['../../**/*.stories.json'],
  addons: [
    '@storybook/addon-controls',
  ],
  webpackFinal: async (config, { configType }) => {
    if(configType == 'PRODUCTION')
      config.output.publicPath = '/view-components/stories/';

    return config;
  },
  managerWebpack: async (config, { configType }) => {
    if(configType == 'PRODUCTION')
      config.output.publicPath = "/view-components/stories/"

    return config;
  }
};
