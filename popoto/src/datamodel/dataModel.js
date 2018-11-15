var dataModel = {};

dataModel.idGen = 0;

dataModel.generateId = function () {
    return dataModel.idGen++;
};

dataModel.nodes = [];
dataModel.links = [];
dataModel.ids = []

dataModel.getRootNode = function () {
    return dataModel.nodes[0];
};

dataModel.inDataNodes = function (label, uuid) {
    return dataModel.nodes
        .filter(function (d) {
            if (d.attributes !== undefined) {
                return parseInt(d.attributes.uuid) == uuid && d.label == label;
            } else if (d.value !== undefined) {
                return parseInt(d.value[0].attributes.uuid) == uuid && d.label == label;
            } else {
                return false
            };
        });
}

dataModel.inDataLinks = function (id_1, id_2) {
    return dataModel.links
        .filter(function (d) {
            return (d.target.id == id_1 && d.source.id == id_2) || (d.target.id == id_2 && d.source.id == id_1);
        })
}

export default dataModel