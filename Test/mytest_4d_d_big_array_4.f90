program main

  USE cmor_users_functions
  implicit none

  integer ncid

  type dims
     integer n
     character(256) name
     character(256) units
     double precision, DIMENSION(:), pointer :: values
     double precision, DIMENSION(:,:), pointer :: bounds     
     type(dims), pointer :: next
  end type dims
  character(256) filein
  type(dims), pointer :: mydims,current
  integer ndim,i,j,ntot,k,l
  double precision, allocatable, dimension(:,:,:,:):: arrayin
!  real, allocatable, dimension(:,:,:,:):: arrayin
  double precision, allocatable :: smallarray(:,:,:)
  integer, dimension(7):: dimlength = (/ (1,i=1,7) /)
  integer, PARAMETER::verbosity = 2
  integer ierr
  integer, allocatable, dimension(:) :: myaxis
  integer myvar
  real amin,amax,mymiss
  double precision bt
  bt=0.
  print*, 'Test Code: hi'
  filein='Test/ta_4D_r.asc'
  open(unit=23,file=filein,form='formatted') 
  call allocate_dims(23,mydims,ndim,dimlength)
  allocate(myaxis(ndim))
  allocate(arrayin(dimlength(1),dimlength(2),dimlength(3),dimlength(4)))
  allocate(smallarray(dimlength(1)+5,dimlength(3)+6,dimlength(4)+7))
  print*,'Test Code: allocate data    :',shape(arrayin),'dims:',dimlength(1),dimlength(2),dimlength(3),dimlength(4)
  print*,'Test Code: allocate data big:',shape(smallarray)
  current=>mydims
  ntot=1
  do i =1,ndim
     ntot=ntot*current%n
     current=>current%next
  enddo
  call read_ascii(23,mydims, ndim,ntot,arrayin)
!!$!! Ok here is the part where we define or variable/axis,etc... 
!!$!! Assuming that Karl's code is ok...
!!$

  print*, 'Test Code: putting everything into the big array contiguous fortran order means faster moving is first element'

  print*,'Test Code: CMOR SETUP'
!!$  
  ierr = cmor_setup(inpath='Test',   &
       netcdf_file_action='replace',                                       &
       set_verbosity=1,                                                    &
       exit_control=1)
    
  print*,'Test Code: CMOR DATASET'
  ierr = cmor_dataset_json("Test/common_user_input.json") 

  current=>mydims
  do i = 0,ndim-1
     print*,'Test Code: CMOR AXIS',i,'AAAAAAA*************************************************************************'
     print*, 'Test Code: Name:',trim(adjustl(current%name))
!!$     print*, 'Test Code: ',current%units
!!$     print*, 'Test Code: ',current%n,size(current%values)
!!$     print*, 'Test Code: ',current%values(1:min(4,size(current%values)))
!!$     print*, 'Test Code: ',current%bounds(1:2,1:min(4,size(current%values)))
     if (trim(adjustl(current%name)).eq.'time') then
        print*, 'Test Code: time found'
  print*, 'Test Code: bounds:',current%bounds,current%units
      myaxis(ndim-i)=cmor_axis('Tables/CMIP6_Amon.json', &
          table_entry=current%name,&
          units=current%units,&
          length=current%n,&
          coord_vals=current%values,&
          cell_bounds=current%bounds, &
          interval='1 month')
     else
     myaxis(ndim-i)=cmor_axis('Tables/CMIP6_Amon.json', &
          table_entry=current%name,&
          units=current%units,&
          length=current%n,&
          coord_vals=current%values,&
          cell_bounds=current%bounds)
        print*, 'Test Code: not time'
     endif
     current=>current%next
  enddo

  print*,'Test Code: CMOR VARCMOR VARCMOR VARCMOR'

  mymiss=1.e20
  myvar=cmor_variable('Tables/CMIP6_Amon.json',&
       'ta',&
       'K',&
       myaxis,&
       missing_value=mymiss)

!! figures out length of dimension other than time

  j=ntot/mydims%n
!!$  print*, 'Test Code: &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
!!$  print*,'Test Code: before:', shape(arrayin),mydims%n
!!$  print*,'Test Code: before:', shape(arrayin(:,i,:))
!!$  print*, 'Test Code: time before:',mydims%next%values(i:i)
  current=>mydims%next%next
print*, 'Test Code: values:',current%values
print*, 'Test Code: bounds:',current%bounds
print*, 'Test Code: N:',current%n
do i=1,current%n
  smallarray=666. ! initialize smallarray at some bad value
  ierr=1
  !put time i into it
  do l = 1, dimlength(4)
     do k = 1, dimlength(3)
        do j = 1, dimlength(1)
           smallarray(j,k,l)=arrayin(j,i,k,l)
        enddo
     enddo
  enddo
  ierr = cmor_write( &
       var_id        = myvar, &
       data          = smallarray, &
       ntimes_passed = 1 &
       )
enddo
ierr = cmor_close(myvar)

contains
  subroutine allocate_dims(file_id,mydims,ndim,dimlength)
    implicit none
    integer i,n,j,tmp,file_id
    integer, intent(inout)::ndim
    integer, intent(inout):: dimlength(7)
    type(dims) , pointer :: tmpdims,mydims
    read(file_id,'(i8)') ndim
!!$    allocate(dimlength(ndim))
    n=1
    allocate(mydims)
    tmpdims=>mydims
    do i = 1, ndim
       read(file_id,'(I8)') tmp
!!$print*,'Test Code: allocatedat:',tmp
       dimlength(5-i)=tmp
       allocate(tmpdims%values(tmp))
       allocate(tmpdims%bounds(2,tmp))
       tmpdims%n=tmp
       allocate(tmpdims%next)
       tmpdims=>tmpdims%next
       n=n*tmp
    enddo
    deallocate(tmpdims)
  end subroutine allocate_dims
  
  subroutine read_ascii(file_unit,mydims,ndim,ntot,arrayin)
    implicit none
    type(dims), pointer::  mydims
    double precision, dimension(:,:,:,:),intent(inout) :: arrayin
!    real, dimension(:,:,:,:),intent(inout) :: arrayin
    type(dims), pointer ::  current
    integer, intent(in)::ndim,file_unit
    integer n,ntot,i,j,k,l,m
    
    current=>mydims
    ntot=1
    do i =1,ndim
       n=current%n
       ntot=ntot*n
       read(file_unit,'(A)') current%name
       print*, 'Test Code: NAME is:',current%name,trim(adjustl(mydims%name))
       if (current%name.eq."pressure") current%name="plev19"
       read(file_unit,'(A)') current%units
       read(file_unit,*) (current%values(j),j=1,n)
       read(file_unit,*) ((current%bounds(j,k),j=1,2),k=1,n)
       print*, 'Test Code: ',current%bounds(1,1),current%bounds(1,2)
       current=>current%next
    enddo
print*, 'Test Code: arrayin shape:',shape(arrayin)
    read(file_unit,*) ((((arrayin(j,k,l,m),j=1,size(arrayin,1)),k=1,size(arrayin,2)),l=1,size(arrayin,3)),m=1,size(arrayin,4))
print*, 'Test Code: done!'
print* ,'Test Code: ',trim(adjustl(mydims%name))
  end subroutine read_ascii

end program main

