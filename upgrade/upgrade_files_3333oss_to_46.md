
# Upgrade from 3.3.33 to 4.6

Below is a description on how to upgrade a out-of-the-box installation of 3.3.33 to 4.6.16.
If you have custom code and config, you may need to do additional steps in order make your code work on 4.6


## Optionally/might be needed by custom code

```
composer require symfony/serializer-pack
```

## Upgrade to latest 3.3
```
composer require ibexa/oss:3.3.41 --with-all-dependencies --no-scripts
# Mentioneded in the upgrade doc, but the following ain't introduced until 4.5ish or so, so skip it for now:
composer config extra.runtime.error_handler "\\Ibexa\\Contracts\\Core\\MVC\\Symfony\\ErrorHandler\\Php82HideDeprecationsErrorHandler"
composer dump-autoload

composer recipes:install ibexa/oss --force -v
composer run post-install-cmd

yarn install
yarn encore prod

php bin/console ibexa:graphql:generate-schema
composer run post-install-cmd
```

## Upgrade to 4.0

Add conflicts to composer.json:
```
"conflict": {
    "jms/serializer": ">=3.30.0",
    "gedmo/doctrine-extensions": ">=3.12.0"
},
```

To avoid following error when upgrading to 4.0.8:
`PHP Fatal error:  Cannot declare class Ibexa\Platform\PostInstall\PostInstall, because the name is already in use in /var/www/vendor/ibexa/post-install/src/lib/PostInstall.php on line 18`

Do workaround before `composer require`:
```
rm -Rf vendor/ibexa/post-install
```

Then upgrade files to 4.0.8
```
composer require ibexa/oss:4.0.8 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
```

### fix config:
```
mv config/packages/ibexa.yaml config/packages/ezplatform.yaml
mv config/packages/ibexa_admin_ui.yaml config/packages/ezplatform_admin_ui.yaml
mv config/packages/ibexa_assets.yaml config/packages/ezplatform_assets.yaml
mv config/packages/ibexa_doctrine_schema.yaml config/packages/ezplatform_doctrine_schema.yaml
mv config/packages/ibexa_http_cache.yaml config/packages/ezplatform_http_cache.yaml
mv config/packages/ibexa_solr.yaml config/packages/ezplatform_solr.yaml
mv config/packages/ibexa_welcome_page.yaml config/packages/ezplatform_welcome_page.yaml
```

At this point, do `git diff` ( diff will show that all your custom changes in standard config files are wiped out).
You need to re-introduce your custom changes as needed. 
You may do that using `git add -p` and skip the parts where your customizations are removed, or
just manually cut&paste your custom changes back into the file, or combination of these two methods.
In general, I would also recommend to put custom config in separate files whenever possible, leaving the shipped files in 
`config/package` as unchanged as possible. That will ease future upgrades.

```
git mv config/packages/ezplatform.yaml config/packages/ibexa.yaml
git mv config/packages/ezplatform_admin_ui.yaml config/packages/ibexa_admin_ui.yaml
git mv config/packages/ezplatform_assets.yaml config/packages/ibexa_assets.yaml
git mv config/packages/ezplatform_doctrine_schema.yaml config/packages/ibexa_doctrine_schema.yaml
git mv config/packages/ezplatform_http_cache.yaml config/packages/ibexa_http_cache.yaml
git add config/packages/ibexa_jms_translation.yaml
git mv config/packages/ezplatform_solr.yaml config/packages/ibexa_solr.yaml
git mv config/packages/ezplatform_welcome_page.yaml config/packages/ibexa_welcome_page.yaml
```

#Now, remove any change in `config/packages/ibexa` which you do *not* want to be commited.

then do
```
git add config/packages/ibexa.yaml config/packages/ibexa_admin_ui.yaml config/packages/ibexa_assets.yaml config/packages/ibexa_doctrine_schema.yaml config/packages/ibexa_http_cache.yaml config/packages/ibexa_solr.yaml config/packages/ibexa_welcome_page.yaml
```

### Fix new routes

Did a short-cut for routes, causes loss of history (in git) for files, but less to type.
Approach also assumes you had *no* local changes to the files in these directories)
( if you want to keep history, you'll need to do `mv` and `git mv` as shown with `ibexa_yaml` files ( and same way of
merging in custom changes).  :

```
git add config/routes/ibexa*
git rm config/routes/ezplatform*
```

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply

```
git commit -m "composer recipes:install ibexa/oss --force -v"
```



Manually remove following from config/bundles.php
```
    eZ\Bundle\EzPublishCoreBundle\EzPublishCoreBundle::class => ['all' => true],
    eZ\Bundle\EzPublishLegacySearchEngineBundle\EzPublishLegacySearchEngineBundle::class => ['all' => true],
    eZ\Bundle\EzPublishIOBundle\EzPublishIOBundle::class => ['all' => true],
    eZ\Bundle\EzPublishDebugBundle\EzPublishDebugBundle::class => ['dev' => true, 'test' => true, 'behat' => true],
    EzSystems\PlatformHttpCacheBundle\EzSystemsPlatformHttpCacheBundle::class => ['all' => true],
    EzSystems\EzPlatformRestBundle\EzPlatformRestBundle::class => ['all' => true],
    EzSystems\EzPlatformCoreBundle\EzPlatformCoreBundle::class => ['all' => true],
    EzSystems\EzPlatformSolrSearchEngineBundle\EzSystemsEzPlatformSolrSearchEngineBundle::class => ['all' => true],
    EzSystems\EzSupportToolsBundle\EzSystemsEzSupportToolsBundle::class => ['all' => true],
    EzSystems\EzPlatformCronBundle\EzPlatformCronBundle::class => ['all' => true],
    EzSystems\PlatformInstallerBundle\EzSystemsPlatformInstallerBundle::class => ['all' => true],
    EzSystems\DoctrineSchemaBundle\DoctrineSchemaBundle::class => ['all' => true],
    EzSystems\EzPlatformContentFormsBundle\EzPlatformContentFormsBundle::class => ['all' => true],
    EzSystems\EzPlatformDesignEngineBundle\EzPlatformDesignEngineBundle::class => ['all' => true],
    EzSystems\EzPlatformStandardDesignBundle\EzPlatformStandardDesignBundle::class => ['all' => true],
    EzSystems\EzPlatformRichTextBundle\EzPlatformRichTextBundle::class => ['all' => true],
    EzSystems\EzPlatformAdminUiBundle\EzPlatformAdminUiBundle::class => ['all' => true],
    EzSystems\EzPlatformUserBundle\EzPlatformUserBundle::class => ['all' => true],
    EzSystems\EzPlatformAdminUiAssetsBundle\EzPlatformAdminUiAssetsBundle::class => ['all' => true],
    EzSystems\EzPlatformEncoreBundle\EzSystemsEzPlatformEncoreBundle::class => ['all' => true],
    EzSystems\EzPlatformMatrixFieldtypeBundle\EzPlatformMatrixFieldtypeBundle::class => ['all' => true],
    EzSystems\EzPlatformGraphQL\EzSystemsEzPlatformGraphQLBundle::class => ['all' => true],
    EzSystems\EzPlatformQueryFieldType\Symfony\EzSystemsEzPlatformQueryFieldTypeBundle::class => ['all' => true],
    Ibexa\Platform\Bundle\Search\IbexaPlatformSearchBundle::class => ['all' => true],
    Ibexa\Platform\Bundle\Assets\IbexaPlatformAssetsBundle::class => ['all' => true],
```

At this time you'll get following error on `clear:cache` : 

`Type "DomainContentByIdentifierConnection" inherited by "UserGroupContentConnection" not found.`
This is due to graphql schema...
delete old "ezplatform" schema : 

```
rm -Rf config/graphql/types/ezplatform
./bin/console c:c
# You want be able to generate new one before db schema is upgraded...
php bin/console ibexa:graphql:generate-schema
```

### Fix yarn

At this time yarn will fail with : Cannot find package '@babel/plugin-proposal-class-properties' imported from /var/www/babel-virtual-resolve-base.js
Get yarn from plain 4.0.8 install, stored in upgrade/yarn.lock.408

```
cp external/ezp-toolkit/upgrade/yarn.lock.408 yarn.lock
yarn install
bin/console ibexa:encore:compile --config-name app
```

Run post install:

```
composer run post-install-cmd
```

### Optional / Depending on custom code:
```
composer require ibexa/compatibility-layer
```

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply 

## Upgrade to 4.1

```
composer require ibexa/oss:4.1.0 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
```

FYI : `post-install-cmd` will fail if executed at this time, but that will be fixed in 4.1.5

```
composer require ibexa/oss:4.1.5 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
```

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply

## Upgrade to 4.2

```
composer require ibexa/oss:4.2.4 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
rm -Rf node_modules
rm -Rf yarn.lock
composer run post-update-cmd
```

FYI : `yarn encore dev --config-name app` will fail. You may try to use yarn.lock from 4.2.4 release or just ignore it for now


Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply

## Upgrade to 4.3

```
composer require ibexa/oss:4.3.5 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
```

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply

## Upgrade to 4.4

```
composer require ibexa/oss:4.4.4 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v

# New files added in this version:
git add assets/scss/welcome-page.scss package.json templates/themes/standard/full/welcome_page.html.twig templates/themes/standard/pagelayout.html.twig translations/ibexa_welcome_page.en.xlf webpack.config.js assets/images/caret-down.svg assets/images/development.svg assets/images/documentation.svg assets/images/header-background.png assets/images/oss.svg assets/images/php-api.svg assets/images/rest-api.svg assets/images/support-background.png assets/images/support.png assets/images/training-background.png assets/images/training.svg assets/images/tutorials-icon.svg assets/images/tutorials.svg assets/images/user.svg assets/js/ assets/scss/_contact.scss assets/scss/_custom-normalize.scss assets/scss/_custom-normalize.scss assets/scss/_documentation.scss assets/scss/_footer.scss assets/scss/_header.scss assets/scss/_main.scss assets/scss/_training.scss assets/scss/_tutorials.scss assets/scss/normalize.css assets/scss/variables.scss
git commit -m "composer recipes:install ibexa/oss --force -v"

composer recipe:install --force --reset -- oneup/flysystem-bundle
git commit config/packages/oneup_flysystem.yaml -m 'composer recipe:install --force --reset -- oneup/flysystem-bundle'
```

Skip on OSS: "Remove ibexa/commerce-* packages with dependencies"

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply

## Upgrade to 4.5

```
composer require ibexa/oss:4.5.7 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
```

skip on OSS: "Define measurement base unit in configuration"


```
git commit config/packages/ibexa_admin_ui.yaml package.json -m "composer recipes:install ibexa/oss --force -v"
```

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply

## Upgrade to 4.6

Upgrade to node >= 18.0.0

```
composer require ibexa/oss:4.6.16 --with-all-dependencies --no-scripts
composer recipes:install ibexa/oss --force -v
yarn add @ckeditor/ckeditor5-alignment@^40.1.0 @ckeditor/ckeditor5-build-inline@^40.1.0 @ckeditor/ckeditor5-dev-utils@^39.0.0 @ckeditor/ckeditor5-widget@^40.1.0 @ckeditor/ckeditor5-theme-lark@^40.1.0 @ckeditor/ckeditor5-code-block@^40.1.0
rm -Rf node_modules
rm yarn.lock
composer run post-install-cmd

```

Skip all config changes  for 4.6.0 mentioned in upgrade doc as they do not apply to OSS

```
composer config extra.runtime.error_handler "\\Ibexa\\Contracts\\Core\\MVC\\Symfony\\ErrorHandler\\Php82HideDeprecationsErrorHandler"
composer dump-autoload
```

Do a `git status` verify that you have commit all needed changes. Discard changes you do not want to apply
