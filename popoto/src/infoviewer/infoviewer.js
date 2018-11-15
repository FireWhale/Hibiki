import rest from "../rest/rest";
import logger from "../logger/logger";
import graph from "../graph/graph";

var infoviewer = {};

infoviewer.containerId = "popoto-info";
infoviewer.QUERY_STARTER = "I'm looking for";
infoviewer.CHOOSE_LABEL = "choose";

/**
 * Create the info viewer area.
 */
infoviewer.createInfoArea = function () {
    var id = "#" + infoviewer.containerId;

    //infoviewer.queryConstraintSpanElements = d3.select(id).append("p").attr("class", "ppt-query-constraint-elements").selectAll(".queryConstraintSpan");
    //infoviewer.querySpanElements = d3.select(id).append("p").attr("class", "ppt-query-elements").selectAll(".querySpan");
};

infoviewer.showInfo = function(node) {
    logger.info("Displaying information in viewer")

    if (node.hasOwnProperty("attributes")) {
        rest.post("model="+node.label+"&id="+node.attributes.uuid, "/interactive_info")
            .done (function (response) {
                $("#popoto-info").eq(0).html(response);
            })
    } else if (node.value !== undefined && node.value[0] !== undefined ) {
        rest.post("model="+node.label+"&id="+node.value[0].attributes.uuid, "/interactive_info")
            .done (function (response) {
                $("#popoto-info").eq(0).html(response);
            })
    }
}

export default infoviewer