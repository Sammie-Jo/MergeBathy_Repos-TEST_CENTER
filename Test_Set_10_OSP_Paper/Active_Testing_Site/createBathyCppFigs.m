%Create Figs
% function createBathyCppFigs 
clear;
%%
% data.utmzone = {'999'};
transpose = 0;
HEADER = 1;
MATLAB_FORMAT = 0;
gxs = [50 10 10 10 10  10 617.33	926		 926]; %grid size x
gys = [50 10 10 10 10  10 617.33	926		 926]; %grid size y
lxs = [50 10 20 20  0  20	   0	1234.67	 1234.67]; %smoothing x
lys = [50 10 20 100 0 100	   0	1234.67	 1234.67]; %smoothing y
LL = 0; % must run MergeBathy with -inputInMeters to get output in meters
filtername = 'hann'; %'boxcar' 'quadloess' 'loess';
errplots = 1; 
smoothplots = 0; 
plot_input = 1; 
plotpts = 0;
scale = 1;	% contours in meters
rect_ll = 0;
local = 0;
useutm = 0;
%  if cntM == 1
% 	 ref_lon = -75.749690; ref_lat = 36.177602; rotation_angle = 18.20;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
%  elseif cntM == 2
% 	ref_lon = -129; ref_lat = 46.5; rotation_angle = 0;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
%  end
% % Determine whether or not to use UTM grid zones
% if (clat == 0 & clon == 0 & rot_angle == 0 & ~rect_ll)
%     useutm = 1;
% end
saveplots = 1;
calcgrid = 1;
nethresh = 0.75;
allownegativedepth = 0; 
modelflag = 1; 
itersmooth = 0; %ALWAYS itersmooth = 0! because CPP doesnt do this

% Directory for output files from MergeBathy to plot
outputDir = 'output_files/';
% bitFlag   = 'x86/';
bitFlag = 'x64/';
% configFlag   = 'Debug';
configFlag = 'Release';
if LL
	ext = '_e'; %'' %
else
	ext = '_e_meters'; 
end

%%
loc = [[outputDir bitFlag] configFlag];

figDir = 'figs';
[s, m1, m2] = mkdir(['../Active_Testing_site/' loc], figDir);
loc = [loc '/'];
figDir = [figDir '/'];

fList= char(['T10C01_CPP_DUCK_50x50g_50x50s' ext '.txt'],...
	['T10C02_CPP_DUCK_10x10g_10x10s' ext '.txt'],...
	['T10C03_CPP_DUCK_10x10g_20x20s' ext '.txt'],...
	['T10C04_CPP_DUCK_10x10g_20x100s' ext '.txt'],...
	['T10C05_CPP_DUCK_10x10g_20x100s_10x10GMT' ext '_xyze.txt'],...
	['T10C05_CPP_DUCK_10x10g_20x100s_10x10GMT' ext '.txt'],...
	['T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ' ext '_xyde.txt'],...
	['T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ' ext '.txt'],...
	['T10C07_CPP_DBDBV_0.5_NoOverlap_MBZK' ext '.txt']);

 figs = char(['T10C01_Duck_50x50g_50x50s' ext],...
	['T10C02_Duck_10x10g_10x10s' ext],... 
	['T10C03_Duck_10x10g_20x20s' ext],...
	['T10C04_Duck_10x10g_20x100s' ext],...
	['T10C05_Duck_10x10g_20x100s_10x10GMT' ext '_xyze'],...
	['T10C05_Duck_10x10g_20x100s_10x10GMT' ext],...
	['T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ' ext '_xyde'],...
	['T10C06_CPP_DBDBV_0.5_NoOverlap_MBZ' ext],...
	['T10C07_CPP_DBDBV_0.5_NoOverlap_MBZK' ext]);
%%
inA = [];
if LL
	insA = {'../../../DATA_CENTER/DUCK_data/ducknsol_xyze.dat',...
			'../../../DATA_CENTER\DUCK_data/duckosol_xyze.dat'};
	insB = {'../../../DATA_CENTER/DBDBV_data/DBDBV_test_0.5data_xyde.txt',...
			'../../../DATA_CENTER/DBDBV_data/DBDBV_test_2.0data_No0.5overlap_xyde.txt'};
else
	insA = {'../../../DATA_CENTER/DUCK_data/ducknsolm_xyze.dat',...
			'../../../DATA_CENTER\DUCK_data/duckosolm_xyze.dat'};
	insB = {'../../../DATA_CENTER/DBDBV_data/DBDBV_test_0.5datam_xyde.txt',...
			'../../../DATA_CENTER/DBDBV_data/DBDBV_test_2.0data_No0.5overlapm_xyde.txt'};
end
insTemp = insA;
ext0 = 'duck';
for cntM=1:2
	for cnt=1:numel(insTemp)
		fileID = fopen(insTemp{cnt},'r');		
		sizeA = [4 Inf];
		[A count] = fscanf(fileID,'%f %f %f %f\n',sizeA);	
		inA = A';
	end

	clear A
	indata.lon = inA(:,1);
	indata.lat = inA(:,2);

	indata.z = inA(:,3);
	indata.e = inA(:,4);

	 if cntM == 1
		 ref_lon = -75.749690; ref_lat = 36.177602; rotation_angle = 18.20;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
	 elseif cntM == 2
		ref_lon = -129; ref_lat = 46.5; rotation_angle = 0;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
	 end
	% Determine whether or not to use UTM grid zones
	if (clat == 0 & clon == 0 & rot_angle == 0 & ~rect_ll)
		useutm = 1;
	end
	if LL
		[indata.x,indata.y,indata.utmzone] = latlon2csas(inA(:,2),inA(:,1),ref_lat,ref_lon,rotation_angle);

		lons = cat(1,indata.lon);
		if(((min(lons) < 0 & max(lons) > 0) & (0-min(lons) > 180+min(lons))))
			if(clon < 0)
				clon = clon + 360;
			end
			for i = 1:length(indata)
				disp('Datasets straddle anti meridian.  Change lons to 0-360.');
				id = find(indata(i).lon < 0);
				indata(i).lon(id) = indata(i).lon(id) + 360;
				[indata(i).x,indata(i).y,indata(i).utmzone] = latlon2csas(indata(i).lat,indata(i).lon,clat,clon,rot_angle);
			end
		end
	else
		indata.x = indata.lon;
		indata.y = indata.lat;
	end
	if (useutm)
		% Set scene center lat/lon for use with UTM gridding
		% Not necessary if local coordinate system specified)
		clat = mean(cat(1,indata.lat));
		clon = mean(cat(1,indata.lon));

		% Make sure all datasets are referenced to the same UTM zone
		for i=1:length(indata)
			zone(i) = indata(i).utmzone(1); %SJZ
		end
		if (any(~strcmp(zone(1),zone)))%find mismatching
		%   disp('UTM zone not consistent between datasets.  Please re-run mergeBathy with a non-zero reference position/rotation angle.');

			%new code:
			%Changed 10/24/14 to reproject each "errant" dataset
			% into the "majority" zone.  Force the zones.  SJZ
			zonestring = '';
			refellip = 23;   % this number corresponds to WGS-84
			for i=1:length(indata)
				zonestring = strcat(zonestring,indata(i).utmzone(1));
			end
			zonestring = char(zonestring);
			for i=1:length(indata)
				agree(i) = length(findstr(zonestring,char(indata(i).utmzone(1))));
			end
			agreeindex = find(agree == max(agree));
			agreeindex = agreeindex(1);
			zone = indata(agreeindex).utmzone(1);
			for i=1:length(indata)
				if (~strcmp(zone,indata(i).utmzone(1)))
					disp('reprojecting UTM coordinates into majority zone');
					indata(i).utmzone = {zone};
					[indata(i).y, indata(i).x, indata(i).utmzone] = ll2UTM(indata(i).lat, indata(i).lon, refellip, zone);
				end
			end
		else
		zone = zone(1);	
		end
	else
		zone = '999';
	end
	x0 = floor(min(cat(1,indata.x)));
	x1 = ceil(max(cat(1,indata.x)));
	y0 = floor(min(cat(1,indata.y)));
	y1 = ceil(max(cat(1,indata.y)));
	% lat0 = min(cat(1,indata.lat));
	% lat1 = max(cat(1,indata.lat));
	% lon0 = min(cat(1,indata.lon));
	% lon1 = max(cat(1,indata.lon));
	if (~rect_ll)
		%   Determine orientation (for mappish display later)
		if (~local)
			if (rot_angle <= 45 | rot_angle > 315)
				flip = 0;
				transpose = 0;
			elseif (rot_angle > 45 & rot_angle <= 135)
				flip = 1;
				transpose = 1;
			elseif (rot_angle > 135 & rot_angle <= 225)
				flip = 1;
				transpose = 0;
			elseif (rot_angle > 225 & rot_angle <= 315)
				flip = 0;
				transpose = 1;
			end
		end
	else
	%         latscale = cos(pi*mean(cat(1,data.lat))/180.0);
	%         llgdx = dx/(deg2km(latscale)*1000); % (111120.0*latscale);
	%         llgdy = dy/(deg2km(1)*1000); % 111120.0;
	%  		xt = lon0-llgdx:llgdx:lon1+llgdx; %wea
	%         yt = lat0-llgdy:llgdy:lat1+llgdy;
	%         [x,y] = meshgrid(xt,yt);
		[i1,i2] = size(x);
		x = reshape(x,i1*i2,1);
		y = reshape(y,i1*i2,1);
	%         [mx,my] = latlon2csas(y,x,clat,clon,rot_angle);
		mx= x; my=y;
		kbound = find(mx >= x0 & mx <= x1 & my >= y0 & my <= y1);
		x = mx(kbound);
		y = my(kbound);
	end
	
	if plot_input
		for cnt2 = 1:3
			figure;
			switch cnt2
				case 1
					plot(indata.x,indata.y,'.');
					titstr = 'Input Soundings';
				case 2
					scatter3(indata.x,indata.y,-1*indata.z,'.');
					titstr = 'Input Soundings [m]';
					if cntM == 1
						daspect([100 100 1]);
					end
				case 3
					scatter3(indata.x,indata.y,indata.e,'.');
					titstr = 'Input Uncertainties [m]';
					if cntM == 1
						daspect([10000 10000 1]);
					end
			end

			axis tight
			title([titstr],'FontSize',16);
			set(gcf,'Name',titstr);
			%zlabel('Depth (m)');
			if (rect_ll)
				xlabel('Longitude (deg)');
				ylabel('Latitude (deg)');
			else
				if (useutm)
					xlabel(sprintf('X (m) UTM [Zone %s]',char(zone)));
					ylabel(sprintf('Y (m) UTM [Zone %s]',char(zone)));
					ah = gca;
					set(ah,'FontSize',8);
					ticks = get(ah,'XTick');
					for k=1:length(ticks);
						newxtick(k,:) = {sprintf('%0.0f',ticks(k))};
					end
					set(ah,'XTickLabel',newxtick);
					set(ah,'XTick',ticks);
					ticks = get(ah,'YTick');
					for k=1:length(ticks);
						newytick(k,:) = {sprintf('%0.0f',ticks(k))};
					end
					set(ah,'YTickLabel',newytick);
					set(ah,'YTick',ticks);
				else
					if (local | ~transpose)
						xlabel('x (m)');
						ylabel('y (m)');
					else
						ylabel('x (m)');
						xlabel('y (m)');
					end
				end
			end
			hold off;

			if (~local)
				if (flip & ~transpose)
					set(gca,'YDir','reverse');
					set(gca,'XDir','reverse');
				elseif (transpose & ~flip)
					set(gca,'XDir','reverse');
				elseif (flip & transpose)
					set(gca,'YDir','reverse');
				end
			end
			drawnow;
			root = [[loc figDir] ];
			if (saveplots)
				graphoutname = strcat(root,[ext0 '_input' num2str(cnt2) '.jpg']);
				saveas(gcf, graphoutname, 'jpg'); % used to be print(graphoutname,'-djpeg');
				graphoutname = strcat(root,[ext0 '_input' num2str(cnt2) '.fig']);
				hgsave(graphoutname);
			end
		end
	end
	if cntM == 1
		indataTemp.A = indata;
		insTemp = insB;
		ext0 = 'dbdbv';
		clear indata;
	elseif cntM == 2
		indataTemp.B = indata;
	end
end
%%
% Plot Outputs from MergeBathy C++
[r,c] = size(fList);
 for cnt = 1:r
	 if cnt > 6
		 indata = indataTemp.B;
	 else
		 indata = indataTemp.A;
	 end
    cFile = fList(cnt,:);
	fileID = fopen([loc cFile],'r');
	if HEADER && (cnt ~= 5 && cnt ~= 7)
		fgetl(fileID);
	end
	if cnt ~= 5 && cnt ~= 7 % SIT output
		if ~MATLAB_FORMAT
			sizeA = [6 Inf];
			[A count] = fscanf(fileID,'%f %f %f %f %f %f\n',sizeA);
		else
			sizeA = [11 Inf];
			[A count] = fscanf(fileID,'%f %f %f %f %f %f %f %f %f %f %f\n',sizeA);	
		end
	else
		sizeA = [4 Inf];
		[A count] = fscanf(fileID,'%f %f %f %f\n',sizeA);
		tempA = sortrows(A');
		A = tempA';		
	end
	fclose(fileID);

	dx = gxs(cnt); %grid size x
	dy = gys(cnt); %grid size y
	lx = lxs(cnt); %smoothing x
	ly = lys(cnt); %smoothing y
	lx0 = lx;
	ly0 = ly;
		
	x = A(1,:);
	y = A(2,:);
	Zi = A(3,:);
	Ei = A(4,:);
	if cnt ~= 5 && cnt ~= 7
		NEi = A(5,:);
		REi = A(6,:);
		if MATLAB_FORMAT
			K_Z = A(10,:);
			K_VAR = A(11,:);
		end
	end

	data(1).x = x(:);
	data(1).y = y(:);
	data(1).lon = x(:);
	data(1).lat = y(:);
	
	%Comment this out to use in Lat Lon
	%Comment in to convert to UTM and do the transposes and
	%orientations
	 if cnt < 5
		 ref_lon = -75.749690; ref_lat = 36.177602; rotation_angle = 18.20;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
	 elseif cntM >= 5
		ref_lon = -129; ref_lat = 46.5; rotation_angle = 0;rot_angle=rotation_angle; clat=ref_lat;clon=ref_lon;
	 end
	% Determine whether or not to use UTM grid zones
	if (clat == 0 & clon == 0 & rot_angle == 0 & ~rect_ll)
		useutm = 1;
	end
	if LL
		[data.x,data.y,data.utmzone] = latlon2csas(A(2,:),A(1,:),ref_lat,ref_lon,rotation_angle);
		xt = round(min(data.x)):dx:max(data.x)+dx;
		yt = round(min(data.y)):dy:max(data.y)+dy;
		
		[x y] = meshgrid(xt,yt);
		F = scatteredInterpolant(data.x',data.y',A(3,:)');
		Zi = F(x,y);
		F = scatteredInterpolant(data.x',data.y',A(4,:)');
		Ei = F(x,y);
		if cnt ~= 5 && cnt ~= 7
			F = scatteredInterpolant(data.x',data.y',A(5,:)');
			NEi = F(x,y);
			F = scatteredInterpolant(data.x',data.y',A(6,:)');
			REi = F(x,y);
			if MATLAB_FORMAT
				K_Z = scatteredInterpolant(data.x',data.y',A(10,:)');
				K_Z = F(x,y);
				K_VAR = scatteredInterpolant(data.x',data.y',A(11,:)');
				K_VAR = F(x,y);
			end
		end
		gridlat=y; gridlon=x; 
	
		lons = cat(1,data.lon);
		if(((min(lons) < 0 & max(lons) > 0) & (0-min(lons) > 180+min(lons))))
			if(clon < 0)
				clon = clon + 360;
			end
			for i = 1:length(data)
				disp('Datasets straddle anti meridian.  Change lons to 0-360.');
				id = find(data(i).lon < 0);
				data(i).lon(id) = data(i).lon(id) + 360;
				[data(i).x,data(i).y,data(i).utmzone] = latlon2csas(data(i).lat,data(i).lon,clat,clon,rot_angle);
			end
		end
	else
		xt = min(data.x):dx:max(data.x);
		yt = min(data.y):dy:max(data.y);	
	end
	if (useutm)
		% Set scene center lat/lon for use with UTM gridding
		% Not necessary if local coordinate system specified)
		clat = mean(cat(1,data.lat));
		clon = mean(cat(1,data.lon));

		% Make sure all datasets are referenced to the same UTM zone
		for i=1:length(data)
			zone(i) = data(i).utmzone(1); %SJZ
		end
		if (any(~strcmp(zone(1),zone)))%find mismatching
		%   disp('UTM zone not consistent between datasets.  Please re-run mergeBathy with a non-zero reference position/rotation angle.');

			%new code:
			%Changed 10/24/14 to reproject each "errant" dataset
			% into the "majority" zone.  Force the zones.  SJZ
			zonestring = '';
			refellip = 23;   % this number corresponds to WGS-84
			for i=1:length(data)
				zonestring = strcat(zonestring,data(i).utmzone(1));
			end
			zonestring = char(zonestring);
			for i=1:length(data)
				agree(i) = length(findstr(zonestring,char(data(i).utmzone(1))));
			end
			agreeindex = find(agree == max(agree));
			agreeindex = agreeindex(1);
			zone = data(agreeindex).utmzone(1);
			for i=1:length(data)
				if (~strcmp(zone,data(i).utmzone(1)))
					disp('reprojecting UTM coordinates into majority zone');
					data(i).utmzone = {zone};
					[data(i).y, data(i).x, data(i).utmzone] = ll2UTM(data(i).lat, data(i).lon, refellip, zone);
				end
			end
		else
		zone = zone(1);	
		end
	else
		zone = '999';
	end
	
    x0 = floor(min(cat(1,data.x)));
    x1 = ceil(max(cat(1,data.x)));
    y0 = floor(min(cat(1,data.y)));
    y1 = ceil(max(cat(1,data.y)));
	lat0 = min(cat(1,data.lat));
    lat1 = max(cat(1,data.lat));
    lon0 = min(cat(1,data.lon));
    lon1 = max(cat(1,data.lon));
	if (~rect_ll)
        %   Determine orientation (for mappish display later)
        if (~local)
            if (rot_angle <= 45 | rot_angle > 315)
                flip = 0;
                transpose = 0;
            elseif (rot_angle > 45 & rot_angle <= 135)
                flip = 1;
                transpose = 1;
            elseif (rot_angle > 135 & rot_angle <= 225)
                flip = 1;
                transpose = 0;
            elseif (rot_angle > 225 & rot_angle <= 315)
                flip = 0;
                transpose = 1;
            end
        end
    else
%         latscale = cos(pi*mean(cat(1,data.lat))/180.0);
%         llgdx = dx/(deg2km(latscale)*1000); % (111120.0*latscale);
%         llgdy = dy/(deg2km(1)*1000); % 111120.0;
%  		xt = lon0-llgdx:llgdx:lon1+llgdx; %wea
%         yt = lat0-llgdy:llgdy:lat1+llgdy;
%         [x,y] = meshgrid(xt,yt);
        [i1,i2] = size(x);
        x = reshape(x,i1*i2,1);
        y = reshape(y,i1*i2,1);
%         [mx,my] = latlon2csas(y,x,clat,clon,rot_angle);
		mx= x; my=y;
        kbound = find(mx >= x0 & mx <= x1 & my >= y0 & my <= y1);
        x = mx(kbound);
        y = my(kbound);
    end
	
	
	
	
	
	
	%Generate Bathymetry Figures===========================================
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if cnt ~= 5 && cnt ~= 7
		nescale = median(NEi(~isnan(NEi))) + 0.1;
		if (nescale > 0.95)
			nescale = 0.95;
		end
		nescale = max(nescale,nethresh);  % removes edge extrapolation effects

		if (min(min(NEi)) > nescale)
			nescale = min(NEi(:)) + 0.1;
		end

		% Changed 4/10/14 for NAVO Test
		if (allownegativedepth) % not sure what Marc has going on here
			ib = find(NEi > nescale); % really poor samples
	% 		ib0 = find(NEi > nescale); 
			ibK = find(NEi > nescale); 
		else
			ib = find(NEi > nescale | Zi < 0.1);
	% 		ib0 = find(NEi > nescale | Zi0 < 0.1);
			if MATLAB_FORMAT
				ibK = find(NEi > nescale | K_Z < 0.1);%sam
			end
		end

		if modelflag % do not nan points below
			ib = []; % nothing is bad
	% 		ib0 = []; 
			if MATLAB_FORMAT
				ibK = []; 
			end
		else
			disp(sprintf('Points with normalized errors greater than %f removed.',nescale));
		end
		% Comment out following if want to keep ALL interpolated points (including where you shouldn't)
		Zi(ib) = Zi(ib)*nan; %WEA
		Ei(ib) = Ei(ib)*nan; %SJZ
		NEi(ib) = NEi(ib)*nan; %SJZ
		REi(ib) = REi(ib)*nan; %SJZ
	% 	Zi0(ib0) = Zi0(ib0)*nan;%SJZ
	% 	STD_Zi(ib0) = STD_Zi(ib0)*nan;%SJZ
		if MATLAB_FORMAT
			K_Z(ibK) = K_Z(ibK)*nan;%SJZ
			K_VAR(ibK) = K_VAR(ibK)*nan;%SJZ
		end
		% disp('nescale NOT being applied as filter');

		if (~itersmooth)
			if (length(lx) == 1 & length(ly) == 1)    % constant smoothing scales
				lx = ones(size(Zi))*lx0;
				ly = ones(size(Zi))*ly0;
			else                                    % dynamic smoothing scales
				lx = griddata(cat(1,data.x),cat(1,data.y),lx,x,y);
				ly = griddata(cat(1,data.x),cat(1,data.y),ly,x,y);
			end
		end
		ib = find(isnan(Zi));
		lx(ib) = ones(size(ib))*nan;
		ly(ib) = ones(size(ib))*nan;
	end
	if (rect_ll)	%%% reformat results into non-cropped array for display purposes
		frame = ones(length(xt)*length(yt),1)*nan; %ngp comment out nan
		frame(kbound) = Zi;
		Zi = frame;
		frame(kbound) = Ei;
		Ei = frame;
		if cnt ~= 5 && cnt ~= 7
			frame(kbound) = NEi;
			NEi = frame;
			frame(kbound) = REi;
			REi = frame;
	% 		frame(kbound) = Zi0;
	% 		Zi0 = frame;
	% 		frame(kbound) = STD_Zi;
	% 		STD_Zi = frame;
			if MATLAB_FORMAT
				frame(kbound) = K_Z;
				K_Z = frame;
				frame(kbound) = K_VAR;
				K_VAR = frame;
			end
			frame(kbound) = lx;
			lx = frame;
			frame(kbound) = ly;
			ly = frame;
		end
		x = mx;
		y = my;
	end

	if (calcgrid)
		if (useutm)
			[gridlat,gridlon] = csas2latlon(x,y,clat,clon,rot_angle,zone);
		else
			[gridlat,gridlon] = csas2latlon(x,y,clat,clon,rot_angle);
		end
		Zi = reshape(Zi,length(yt),length(xt));
		Ei = reshape(Ei,length(yt),length(xt));
		if cnt ~= 5 && cnt ~= 7
			NEi = reshape(NEi,length(yt),length(xt));
			REi = reshape(REi,length(yt),length(xt));
	% 		Zi0 = reshape(Zi0,length(yt),length(xt));
	% 		STD_Zi = reshape(STD_Zi,length(yt),length(xt));
			if MATLAB_FORMAT
				K_Z = reshape(K_Z,length(yt),length(xt));
				K_VAR = reshape(K_VAR,length(yt),length(xt));
			end
			lx = reshape(lx,length(yt),length(xt));
			ly = reshape(ly,length(yt),length(xt));
		end
		gridlat = reshape(gridlat,length(yt),length(xt));
		gridlon = reshape(gridlon,length(yt),length(xt));
% 		outx = reshape(x,length(yt),length(xt));
% 		outy = reshape(y,length(yt),length(xt));
	end

	if (~local)
		if (transpose)
			Zi = Zi';
			Ei = Ei';
			if cnt ~= 5 && cnt ~= 7
				NEi = NEi';
				REi = REi';
	% 			Zi0 = Zi0';
	% 			STD_Zi = STD_Zi';
				if MATLAB_FORMAT
					K_Z = K_Z';
					K_VAR = K_VAR';
				end
				lx = lx';
				ly = ly';
			end
			%Added 4/10/14 for NAVO Test
% 			outx = outx';
% 			outy = outy';
			if (calcgrid)
				gridlat = gridlat';
				gridlon = gridlon';
			end
			temp = yt;
			yt = xt;
			xt = temp;
		end
	end
	
	% Determine which graphics to display

	root = [[loc figDir] figs(cnt,:)];
	if (errplots)
		if cnt ~= 5 && cnt ~= 7
			toshow = 1:2;
		%     toshow = 1:8;
			if MATLAB_FORMAT
				toshow = [toshow 7 8];
			end
		else
			toshow = 1:2;
		end
	else
		toshow = 1;
	end
	if (smoothplots)
	%     toshow = [toshow, 5, 6];
		toshow = [toshow, 9, 10];
	end
	if(calcgrid)
		minZ = 0;
		minlat = min(min(floor(gridlat*30)/30));
		maxlat = max(max(ceil(gridlat*30)/30));
		minlon = min(min(floor(gridlon*30)/30));
		maxlon = max(max(ceil(gridlon*30)/30));

		for j=1:length(toshow)
			ZiTemp = Zi;
			maxZ = ceil(max(max(Zi)));
			% select the error field to show
			figure
			switch toshow(j)
				case 1
					E = -1*Zi(:,:);
					if (scale == 1)
						titstr = 'Bathymetric Surface [m]';
					else
						titstr = 'Bathymetric Surface [ft]';
					end
					colormap((jet));
% 					colormap(flipud(jet)); % blue water, warm land
					graphextension = '';
				case 2
					E = Ei(:,:);
					if cnt ~= 5 && cnt ~= 7
						if (scale == 1)
	% 						titstr = 'rms error estimate (Ei) (m)';
							titstr = 'Uncertainty Estimate [m]';
						else
	% 						titstr = 'rms error estimate (Ei) (ft)';
							titstr = 'Uncertainty Estimate (ft)';
						end
					else
						titstr = 'Uncertainty Estimate [m]';
					end
					colormap((jet)); % hot errors
					graphextension = '_rmserr';%'_rmsres'; %sam 
				case 3
					E = NEi(:,:);
					titstr = 'normalized error estimate';
					colormap((jet)); % hot errors
					graphextension = '_normrms';
				case 4
					E = REi(:,:);
					if (scale == 1)
						titstr = 'residual error estimate (m)';
					else
						titstr = 'residual error estimate (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_rmsres';%'_rmserr';%sam
				case 5
					% updated ZiTemp to reflect PropUncert depths in contours
					ZiTemp = Zi0;
					maxZ = ceil(max(max(Zi0)));
					E = Zi0(:,:);
					if (scale == 1)
						titstr = 'PropUncert Bathymetric surface [m]';
					else
						titstr = 'PropUncert Bathymetric surface [ft]';
					end
					colormap(flipud(jet)); % blue water, warm land
					graphextension = '_zi0';
				case 6
					% updated ZiTemp to reflect PropUncert depths in contours
					ZiTemp = Zi0;
					maxZ = ceil(max(max(Zi0)));
					E = STD_Zi(:,:);
					if (scale == 1)
						titstr = 'PropUncert error estimate (m)';
					else
						titstr = 'PropUncert error estimate (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_stdzi';
				case 7
					% updated ZiTemp to reflect Kalman depths in contours
					ZiTemp = K_Z;
					maxZ = ceil(max(max(K_Z)));
					E = K_Z(:,:);
					if (scale == 1)
						titstr = 'Kalman Bathymetric surface [m]';
					else
						titstr = 'Kalman Bathymetric surface [ft]';
					end
					colormap(flipud(jet)); % blue water, warm land
					graphextension = '_kz';
				case 8
					% updated ZiTemp to reflect Kalman depths in contours
					ZiTemp = K_Z; 
					maxZ = ceil(max(max(K_Z)));
					E = K_VAR(:,:);
					if (scale == 1)
						titstr = 'Kalman error estimate (m)';
					else
						titstr = 'Kalman error estimate (ft)';
					end
					colormap((jet)); % hot errors
					graphextension = '_kvar';
				case 9
					E = lx(:,:);
					titstr = 'X smoothing scales (m)';
					colormap((jet)); % hot errors
					graphextension = '_lx';
				case 10
					E = ly(:,:);
					titstr = 'Y smoothing scales (m)';
					colormap((jet)); % hot errors
					graphextension = '_ly';
			end

			pcolor(xt,yt,E); shading('interp'); %was shading flat - but that displaces array!!

			rightrange = round(caxis*10)/10; % workaround to fix bug in matlab7 contour
			%Added 10/16/15 to fix non-increasing values SJZ
			if(rightrange(1)==rightrange(2))
				rightrange = caxis;
			end
			h = colorbar;
			hold on;

			dZset = [1 2 5 10 20 25 50 100];
			dZind = 1;
			numCont = length(minZ:dZset(dZind):maxZ);
			while (numCont > 20 && dZind < 8)
				dZind = dZind + 1;
				numCont = length(minZ:dZset(dZind):maxZ);
			end
			dZ = dZset(dZind);

			[c h] = contour(xt,yt,ZiTemp(:,:),minZ:dZ:maxZ, '-'); % every meter
			hand = h;
			for k=1:length(h)
				set(h(k),'LineStyle','-', 'color', 'b');
			end
			clabel(c,h,minZ:2*dZ:maxZ,'FontSize',12);
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			dlat = ((maxlat-minlat)*60)/2;
			if dlat > 20
				dlat = 20;
			elseif dlat > 2
				dlat = 2;
			end

			[c2,h2] = contour(xt,yt,gridlat,minlat:dlat/60:maxlat, 'r-');
			if (length(h2) >= 1)
				clabel(c2,h2,minlat:dlat/60:maxlat,'Color', 'r');
			end

			dlon = ((maxlon-minlon)*60)/2;

			[c3,h3] = contour(xt,yt,gridlon,minlon:dlon/60:maxlon, 'r-');
			caxis(rightrange); % reset to original
			if (length(h3) >= 1)
				clabel(c3,h3,minlon:dlon/60:maxlon,'Color', 'r');
			end

			axis([min(xt) max(xt) min(yt) max(yt)]); % do this now before plotting points
			axis('image');
			axis xy;
			
			if toshow(j) == 2
				if cnt < 6
					caxis([0 0.1]);
				elseif cnt > 7
					caxis(cc3/5);
				end
				hold on; plot(indata.x,indata.y,'m.','markersize',1)
			end
			
			if plotpts
				if ~rect_ll
					if (local | ~transpose)
						plot(cat(1,data.x),cat(1,data.y), 'm.', 'markersize',3);
					else
						plot(cat(1,data.y),cat(1,data.x), 'm.', 'markersize',3);
					end
				else
					plot(cat(1,data.lon),cat(1,data.lat), 'm.', 'markersize',3);
				end
			end

			title([titstr],'FontSize',16);
			set(gcf,'Name',titstr);
			if (rect_ll)
				xlabel('Longitude (deg)');
				ylabel('Latitude (deg)');
			else
				if (useutm)
					xlabel(sprintf('X (m) UTM [Zone %s]',char(zone)));
					ylabel(sprintf('Y (m) UTM [Zone %s]',char(zone)));
					ah = gca;
					set(ah,'FontSize',8);
					ticks = get(ah,'XTick');
					for k=1:length(ticks);
						newxtick(k,:) = {sprintf('%0.0f',ticks(k))};
					end
					set(ah,'XTickLabel',newxtick);
					set(ah,'XTick',ticks);
					ticks = get(ah,'YTick');
					for k=1:length(ticks);
						newytick(k,:) = {sprintf('%0.0f',ticks(k))};
					end
					set(ah,'YTickLabel',newytick);
					set(ah,'YTick',ticks);
				else
					if (local | ~transpose)
						xlabel('x (m)');
						ylabel('y (m)');
					else
						ylabel('x (m)');
						xlabel('y (m)');
					end
				end
			end
			hold off;

			if (~local)
				if (flip & ~transpose)
					set(gca,'YDir','reverse');
					set(gca,'XDir','reverse');
				elseif (transpose & ~flip)
					set(gca,'XDir','reverse');
				elseif (flip & transpose)
					set(gca,'YDir','reverse');
				end
			end
			drawnow;

			if (saveplots)
			graphoutname = strcat(root,'_bathy_',filtername,graphextension,'.jpg');
			saveas(gcf, graphoutname, 'jpg'); % used to be print(graphoutname,'-djpeg');
			graphoutname = strcat(root,'_bathy_',filtername,graphextension,'.fig');
			hgsave(graphoutname);
			end
		end
	end	% whether or not to display results
 end
 
 
