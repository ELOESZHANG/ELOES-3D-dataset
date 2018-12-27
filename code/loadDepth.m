function Depth=loadDepth(depthPath)
    image_list=dir(depthPath);
    image_names={};
    for image_index=1:length(image_list)
        if ~strcmp(image_list(image_index).name,'.')...
                &&~strcmp(image_list(image_index).name,'..')...
                &&(strcmp(image_list(image_index).name(end-2:end),'bmp')...
                ||strcmp(image_list(image_index).name(end-2:end),'png')...
                ||strcmp(image_list(image_index).name(end-2:end),'jpg'))
            image_names{length(image_names)+1}=image_list(image_index).name;
        end
    end
    image_names=sort(image_names);
    Depth={};
    for image_index=1:length(image_names)
        Temp=imread([depthPath image_names{image_index}]);
        imgResized=imgResize(Temp);
        Depth{image_index,1}=imgResized;
    end
end