import * as d3 from "d3";
import {version} from "../dist/package";
import dataModel from "./datamodel/dataModel";
import graph from "./graph/graph";
import logger from "./logger/logger";
import provider from "./provider/provider";
import infoviewer from "./infoviewer/infoviewer";
import rest from "./rest/rest";
import taxonomy from "./taxonomy/taxonomy";

/**
 * Main function to call to use Popoto.js.
 * This function will create all the HTML content based on available IDs in the page.
 *
 * @param startParam Root label or graph schema to use in the graph query builder.
 */
//TODO add instance creation + config
export function start(startParam) {
    logger.info("Popoto " + version + " start on " + startParam);

    graph.mainLabel = startParam;

    if (rest.CYPHER_URL === undefined) {
        logger.error("popoto.rest.CYPHER_URL is not set but is required.");
    } else {
        // TODO introduce component generator mechanism instead for future plugin extensions
        checkHtmlComponents();

        if (taxonomy.isActive) {
            taxonomy.createTaxonomyPanel();
        }

        if (graph.isActive) {
            graph.createGraphArea();
            graph.createForceLayout();

            if (typeof startParam === 'string' || startParam instanceof String) {
                var labelSchema = provider.node.getSchema(startParam);
                if (labelSchema !== undefined) {
                    graph.addSchema(labelSchema);
                } else {
                    graph.addRootNode(startParam);
                }
            } else {
                graph.loadSchema(startParam);
            }
        }


        if (infoviewer.isActive) {
            infoviewer.createInfoArea();
        }

        if (graph.USE_VORONOI_LAYOUT === true) {
            graph.voronoi.extent([[-popoto.graph.getSVGWidth(), -popoto.graph.getSVGWidth()], [popoto.graph.getSVGWidth() * 2, popoto.graph.getSVGHeight() * 2]]);
        }

        update();
    }
}

/**
 * Check in the HTML page the components to generate.
 */
function checkHtmlComponents() {
    var graphHTMLContainer = d3.select("#" + graph.containerId);
    var taxonomyHTMLContainer = d3.select("#" + taxonomy.containerId);
    var infoHTMLContainer = d3.select("#" + infoviewer.containerId);

    if (graphHTMLContainer.empty()) {
        logger.debug("The page doesn't contain a container with ID = \"" + graph.containerId + "\" no graph area will be generated. This ID is defined in graph.containerId property.");
        graph.isActive = false;
    } else {
        graph.isActive = true;
    }

    if (taxonomyHTMLContainer.empty()) {
        logger.debug("The page doesn't contain a container with ID = \"" + taxonomy.containerId + "\" no taxonomy filter will be generated. This ID is defined in taxonomy.containerId property.");
        taxonomy.isActive = false;
    } else {
        taxonomy.isActive = true;
    }

    if (infoHTMLContainer.empty()) {
        logger.debug("The page doesn't contain a container with ID = \"" + infoviewer.containerId + "\" no query viewer will be generated. This ID is defined in infoviewer.containerId property.");
        infoviewer.isActive = false;
    } else {
        infoviewer.isActive = true;
    }

}

/**
 * Function to call to update all the generated elements including svg graph, query viewer and generated results.
 */
export function update() {
    updateGraph();

    // Do not update if rootNode is not valid.
    var root = dataModel.getRootNode();

    if (!root || root.label === undefined) {
        return;
    }
}

/**
 * Function to call to update the graph only.
 */
export function updateGraph() {
    if (graph.isActive) {
        // Starts the D3.js force simulation.
        // This method must be called when the layout is first created, after assigning the nodes and links.
        // In addition, it should be called again whenever the nodes or links change.
        graph.link.updateLinks();
        graph.node.updateNodes();

        // Force simulation restart
        graph.force.nodes(dataModel.nodes);
        graph.force.force("link").links(dataModel.links);
        graph.force.alpha(1).restart();
    }
}