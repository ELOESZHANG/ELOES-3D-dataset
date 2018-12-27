function resizedImage=imgResize(img)
    maxedge=400;
    edge=length(img);
    if( edge > maxedge )
        scale = maxedge / edge;
        resizedImage = imresize( img, scale, 'Antialiasing', false );
    else 
        resizedImage=img;
     end
end