% Jason Sun (#20387090)
loadScript
MAX_NODES = 10;
% tree = dtl(trainDataSparse, , MAX_NODES);
% info_list = zeros(length(trainDataSparse),1);
info_list = importance(trainDataSparse, trainLabel);

