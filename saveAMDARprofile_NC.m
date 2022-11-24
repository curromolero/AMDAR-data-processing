function [status] = saveAMDARprofile_NC(direccionFichero, AMDARprofile)
% Funcion que guarda los detalles y las variables para cada aterrizaje en
% la base de datos AMDAR sobre Madrid en formato netCDF (*.nc)
    % borra el fichero si existe
    if exist(direccionFichero, 'file')
        delete(direccionFichero)
    end
    
    % Graba los datos del array AMDARprofile
    nccreate(direccionFichero, 'date', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 1))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'date', AMDARprofile(:, 1));
    ncwriteatt(direccionFichero, 'date', 'long_name', 'date of landing');
    ncwriteatt(direccionFichero, 'date', 'standard_name', 'date');
    
    nccreate(direccionFichero, 'Latitude', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 2))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'Latitude', AMDARprofile(:, 2));
    ncwriteatt(direccionFichero, 'Latitude', 'units', 'degrees_North');
    ncwriteatt(direccionFichero, 'Latitude', 'long_name', 'Latitude of aircraft');
       
    nccreate(direccionFichero, 'Longitude', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 3))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'Longitude', AMDARprofile(:, 3));
    ncwriteatt(direccionFichero, 'Longitude', 'units', 'degrees_east');
    ncwriteatt(direccionFichero, 'Longitude', 'long_name', 'Longitude of aircraft');
    
    nccreate(direccionFichero, 'Altitude', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 4))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'Altitude', AMDARprofile(:, 4));
    ncwriteatt(direccionFichero, 'Altitude', 'units', 'm_asl');
    ncwriteatt(direccionFichero, 'Altitude', 'long_name', 'Altitude of aircraft, m above sea level');
    
    nccreate(direccionFichero, 'WindDir', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 5))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'WindDir', AMDARprofile(:, 5));
    ncwriteatt(direccionFichero, 'WindDir', 'units', 'degrees');
    ncwriteatt(direccionFichero, 'WindDir', 'long_name', 'Wind direction from North');
    
    nccreate(direccionFichero, 'WindSp', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 6))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'WindSp', AMDARprofile(:, 6));
    ncwriteatt(direccionFichero, 'WindSp', 'units', 'm/s');
    ncwriteatt(direccionFichero, 'WindSp', 'long_name', 'Wind speed');
    
    nccreate(direccionFichero, 'Temp', 'Datatype', 'double', ...
        'Dimensions',{'Altitude', length(AMDARprofile(:, 7))}, 'Format', 'netcdf4');
    ncwrite(direccionFichero, 'Temp', AMDARprofile(:, 7));
    ncwriteatt(direccionFichero, 'Temp', 'units', 'Kelvin degrees');
    ncwriteatt(direccionFichero, 'Temp', 'long_name', 'Temperature in Kelvin degrees');
    
    % Grabando los atributos globales recogidos en la variable attGlobales
    ncwriteatt(direccionFichero, '/', 'start_datetime', AMDARprofile(1, 1));
    ncwriteatt(direccionFichero, '/', 'stop_datetime', AMDARprofile(end, 1));
    ncwriteatt(direccionFichero, '/', 'title',  'Profile from AMDAR' );
    ncwriteatt(direccionFichero, '/', 'data_processing_institution', 'CIEMAT' );
    
    status = 0;