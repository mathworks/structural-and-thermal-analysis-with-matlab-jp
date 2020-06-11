% Helper function to generate App designer 3D plot
% Copyright 2018 The MathWorks, Inc.
function pde3DResults(ha,thepde,time_step,varargin)

themsh = thepde.Mesh;
[p,~,t] = themsh.meshToPet();
parser = inputParser;
addParameter(parser,'colormapdata', []);
addParameter(parser,'flowdata', [], @isnumeric);
addParameter(parser,'Deformation', []);
addParameter(parser,'DeformationScaleFactor', [], @isnumeric);
addParameter(parser,'NodeLabels', 'off', @isValidNdLabelOption);
addParameter(parser,'ElementLabels', 'off', @isValidElLabelOption);
addParameter(parser,'Mesh', 'off', @isValidMeshDispOption);
addParameter(parser,'FaceAlpha', 1, @isnumeric);
parse(parser,varargin{:});
colormapdata = parser.Results.colormapdata(:,time_step);
faceAlpha = parser.Results.FaceAlpha;
deformation = parser.Results.Deformation;
scaleFactor = parser.Results.DeformationScaleFactor;


numElemNodes = size(t,1) - 1;
hf = get(ha,'Parent');
set(hf,'Color','white');
set(ha,'ClippingStyle','rectangle');

bbox = [min(p(1,:)) max(p(1,:));
    min(p(2,:)) max(p(2,:));
    min(p(3,:)) max(p(3,:))];

if ~isempty(deformation)
    xdisp = deformation.ux(:,time_step);
    ydisp = deformation.uy(:,time_step);
    zdisp = deformation.uz(:,time_step);
end

if isempty(scaleFactor)
    MaxDeformationMag = max(max(sqrt(deformation.ux.^2+deformation.uy.^2+deformation.uz.^2)));
    if MaxDeformationMag ~= 0
        scaleFactor = 2.5*min(bbox(:,2) - bbox(:,1)) /MaxDeformationMag; % Based on lowest bounding box dimension
    else
        scaleFactor = 1;
    end
end

if ~isempty(deformation)
    pmax(1,:) = p(1,:) +  scaleFactor*max(deformation.ux,[],2)';
    pmax(2,:) = p(2,:) +  scaleFactor*max(deformation.uy,[],2)';
    pmax(3,:) = p(3,:) +  scaleFactor*max(deformation.uz,[],2)';
    
    pmin(1,:) = p(1,:) +  scaleFactor*min(deformation.ux,[],2)';
    pmin(2,:) = p(2,:) +  scaleFactor*min(deformation.uy,[],2)';
    pmin(3,:) = p(3,:) +  scaleFactor*min(deformation.uz,[],2)';
    
    bboxDef = [min(pmin(1,:)) max(pmax(1,:));
        min(pmin(2,:)) max(pmax(2,:));
        min(pmin(3,:)) max(pmax(3,:))];
    
    aLims = [bboxDef(1,1), bboxDef(1,2), bboxDef(2,1), bboxDef(2,2), bboxDef(3,1), bboxDef(3,2)];
    
end

axis(ha,'equal');
axis(ha, aLims)
axis(ha,'off');

if ~isempty(deformation)
    p(1,:) = p(1,:) +  scaleFactor*xdisp';
    p(2,:) = p(2,:) +  scaleFactor*ydisp';
    p(3,:) = p(3,:) +  scaleFactor*zdisp';
end

if ~isempty(colormapdata)
    [ltri] = tetBoundaryFacets(p,t(1:end-1,:));
    if(numElemNodes == 10)
        ltri = splitQuadraticTri(ltri);
    end
    
    colormap(ha,'jet');
    
    patch('Faces',ltri, 'Vertices', p', 'FaceVertexCData', colormapdata(:), ...
        'AmbientStrength', .75,  ...
        'EdgeColor', 'none', 'FaceColor', 'interp', 'parent',ha,'FaceAlpha',faceAlpha, 'Clipping','off');
end

hold(ha,'off');
view(ha,[30 30]);
colorbar(ha)

end

function t4=splitQuadraticTri(t)
t4Nodes = [1 4 6; 4 5 6; 4 2 5; 6 5 3];
t4 = [t(:,t4Nodes(1,:)); t(:,t4Nodes(2,:)); t(:,t4Nodes(3,:)); t(:,t4Nodes(4,:))];
end
