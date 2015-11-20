function morph3dwrapper(focused_path,focused_image_rgb,height_map,image_name,sampleID,calibration,num_slices,zstep,kernel_size_OF,downsample_grid_size,savePDF,mbb_path,geom3d_path,mesh2pdf_path)
% Runs suite of morph3D functions to:
%   1) Extract 3D Mesh from heightmap generated using StackFocuser
%   2) Generate 3D PDF (if generate_pdf == True)
%   3) Output OBJ file for downstream morphometrics processing

% Build 'morph3d' path
morph3d_path = fullfile(focused_path,'morph3d');

% Generate mesh
time_start = datestr(now);
disp(strcat('Start: ',time_start))
try
	[skipped,coordinates,top_surface_area,xy_points,z_values,X,Y,Z] = generateMesh(focused_image_rgb,height_map,image_name,sampleID,calibration,num_slices,zstep,kernel_size_OF,downsample_grid_size);
catch
	warning('Cannot generate mesh!')
	exit()
end

if skipped == true
    % Isolate skipped object folder as necessary
    moveSkipped(morph3d_path,skipped,image_name);
    disp('Object %s skipped',image_name);    
else
    % Write coordinates file
    writeCoordinates(morph3d_path,image_name,coordinates);

    % Calculate (and write to .csv file) volumes assuming 1) dome base; 2) pyramid base; 3) cube base
    getVolumeSurfaceArea(morph3d_path,image_name,mbb_path,xy_points,z_values,coordinates,top_surface_area,downsample_grid_size);
    
    % Write OBJ and OFF s
    writeOBJOFF(morph3d_path,image_name,geom3d_path,coordinates);
    
    % 3D PDF preprocessing (if specified)
    if savePDF == true || isempty(savePDF)
    	pdfPreprocess(morph3d_path,mesh2pdf_path,image_name,X,Y,Z);
    end
time_end = datestr(now);
disp(strcat('End: ',time_end))
end

