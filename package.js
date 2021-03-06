Package.describe({
  summary: "isolate reactive values"
});

Package.on_use(function (api) {
  api.use([
    'coffeescript',
    'ejson'
  ], 'client');

  if (api.export)
    api.export('isolateValue', 'client');

  api.add_files([
    'isolate.coffee'
  ], 'client');
});

Package.on_test(function (api) {
  api.use([
    'coffeescript',
    'tinytest'
  ]);
  api.use('isolate-value', 'client');
  api.add_files('isolate-tests.coffee', 'client');
});
