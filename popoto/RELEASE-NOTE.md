## popoto-2.0
2018/05/05

* Added fit text option. 
* Updated to D3 V5.
* Packaged code as a module.
* Added donut representation of node relations around the node in graph.
* Nodes are now displayed as circle instead of ellipses.
* Added circle clipPath on node with images to fit in node circle.
* Added provider to set link color. (the color is also used in donut)
* Removed plus sign on nodes to expand relationships
* Added click on links to remove them.
* Removed background highlight circle.
* Added TOGGLE_VIEW_RELATION toolbar action.
* Added SVG defs elements like circle clip path for nodes with images and markers for links. Set popoto.graph.link.SHOW_MARKER to true to display them.
* Added functions addExpandedValue and removeExpandedValue to allow value selection from outside of the graph.
* Added new events on graph actions.
* Added incoming relation in node properties to allow finer customization.
* Added support of multiple selection on node values which allow OR conditions on generated cypher queries and right click now remove last selected value on a node.
* Updated graph events code and added event customization on graph reset, node data loaded.
* Added isCollapsed state in graph schema.
* Added autoLoadValue in provider configuration to preload node value instead of on node click.
* Fixed graph save containing expanded values.
* Added support of not value in nodes.
* Added getSize option in node configuration to allow dynamic size depending on node attributes.
* Changed results and page size properties, popoto.result.RESULTS_PAGE_SIZE define the number of results displayed in result component, and popoto.query.MAX_RESULTS_COUNT
     define the number of results returned in cypher query.
* Added ajax execution optimization to avoid inconsistent data.

## popoto-1.1.2
 2017-05-02

* Fixed textPath issue update on Edge browser.
* Added popoto.graph.DISABLE_COUNT property to disable all counts on nodes.
* Added "schema" property in label providers to auto generate graph in popoto for a label without retrieving relation on database.
* Added support of predefined graph schema in start function to open graph in a predefined state.

## popoto-1.1.1
 2017-01-23

* Removed "Asap" font and set default to "sans-serif".
* Added Custom popoto font to use as icons in page.
* Replaced taxonomies and menu icon with font icons.

## popoto-1.1.0
 2016-12-28

* Minor fixes on Cypher viewer.
* Added use of parameters in generated queries.
* Fixed internal errors when some data is invalid or missing in REST API call.
* Removed extra query execution to get result count, the count was already available in root node.
* Added support of graph results, this feature can be used to display the results as a graph instead of rows like in Neo4j Browser.
* Added support of new configuration options:
  * "filterResultQuery", "filterNodeValueQuery", "filterNodeCountQuery", "filterNodeRelationQuery" to customize generated Cypher queries depending on labels.
  * "autoExpandRelations" to automatically expand nodes with a specific labels. This can be used to pre-open graph on page load.
* Fixed nodes Drag behavior, nodes now are no more opened or collapsed when they are dragged on graph.

## popoto-1.0
 2015-11-03

* Added Cypher query viewer support.
* Added first version of Configurator.
* Removed app template js file, everything is in the index.html page now.
* Changed generated taxonomies elements to use css image.
* Fixed default display results on internal Neo4j IDs.

## popoto-0.0.a6
 2015-06-21

* Added support of predefined constraints in node configuration.
* Added better handling of query execution errors.

## popoto-0.0.a5
 2015-04-25

* Modified default label provider to display all returned attributes with their value by default in the result list instead of constraint attribute only.
* Added different CSS classes for ellipses when value is selected for root and choose nodes. Also added disabled style on root node if no results are found in the database.

## popoto-0.0.a4
 2015-04-19

* Transition to transactional Cypher HTTP endpoint. Cypher queries are now executed using transactional HTTP endpoint instead of deprecated legacy API.
* Count query optimization, all count queries are now sent on the same REST call using a list of statements. (better performance on distant databases)
* Added new CSS styles for nodes and links when count is "0" (disabled node state)
* Added new property "popoto.graph.WHEEL_ZOOM_ENABLED" to disable zoom with mouse wheel on graph.
* Added properties to add/disable tool items in graph.
* Introduced new property "popoto.query.USE_RELATION_DIRECTION" to define whether or not generated Cypher queries will use directed relationship.
* Added a plus sign icon button on nodes to get relationships instead of right click. Right click is now only used to remove a selection.
* Added a minus sign icon button on nodes after relation have been expanded. click on this button will remove all the relations from this node.
* Added reset graph tool option.
* Added different CSS classes on relation links to be able for example to differentiate links with value ("ppt-link-relation" and "ppt-link-relation value").
* Added a new property "popoto.graph.link.RADIUS" to define the radius around the node to start link drawing (nicer on transparent node images).
* Refactored node svg generation to fully support dynamic type changes (e.g use SVG node type for node label and image for selectable values)
* Added different CSS classes on node highlight background circle (shown on node hover) to be able to customize it depending on node type.
* Added listener on root node add event to allow for example to set a specific value on root node when added.
* Added immutable state on nodes to be able to add unchangeable constraint on graph. Immutable nodes value constraints are used in relations query which will avoid relation on nodes with 0 values.
* Added configuration to allow filter of relations. This can be used to hide unwanted relation from the graph.
* Added configuration to define whether the list of relation with same parent label should be grouped or separated using last child label with the property popoto.query.USE_PARENT_RELATION.
      The generated Cypher query use head(labels(x)) or last(labels(x)) to get the relation target node label.

## popoto-0.0.a3
 2015-03-26

* Fixed constraint generation in query for root node with non string attributes. (double quotes were always used in Cypher generation on root node constraint even for numeric and boolean values)
* Added a taxonomy label provider and extracted a few internal labels to fully support localization.
* Extracted node text y position in variable to be able to customize it
* Extracted some internal labels to allow localization
* Extracted popoto.graph.centerRootNode function to allow root node move after HTML component resize for example
* Added node shadow highlight on node hover
* Used text value on node title instead of semantic value

## popoto-0.0.a2
 2015-03-16

* Updated AJAX request body to execute Cypher queries on Neo4j REST API with authentication support.
    Neo4j 2.2 and GrapheneDB are now supported with this change.
    Transition to the new transactional endpoint is not yet ready, legacy Cypher HTTP endpoint is still used in this version.
* Added sort attribute in configuration for value query.
    It is now possible to use the constraint attribute to sort the values displayed on node click instead of count (count is still used by default).
    The order can also be specified to be ascending or descending.
* Removed default returned internal Neo4j id if any other attribute is provided in configuration.

Popoto.js 0.0.a1
 2015-02-10

* First public release

