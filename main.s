;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@date				 31.01.2021
;
;@PROJECT GROUP
;@Group No: 30
;@Zafer Yildiz 			150170054
;@Basar Demir  			150180080
;@Muhammed Salih Yildiz 150180012
;@Burak Sen 			150170063
;@Mehmet Can Gün 		150160802
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------															
							


;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
							


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
				BL	Clear_Alloc				; Call Clear Allocation Function.
				BL  Clear_ErrorLogs			; Call Clear ErrorLogs Function.
				BL	Init_GlobVars			; Call Initiate Global Variable Function.
				BL	SysTick_Init			; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS		; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]				; Load Program Status Variable.
				CMP	R1, #2					; Check If Program finished.
				BNE LOOP					; Go to loop If program do not finish.
STOP			B	STOP					; Infinite loop.
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------															
				EXPORT SysTick_Handler
				PUSH {LR}					; Push LR to stack to preserve
				LDR  R3, =TICK_COUNT		; Address of Tick_Count -> R3
				LDR  R4, [R3]				; Tick_Count -> R4
				ADDS R4, R4, #1				; Tick_Count += 1
				STR  R4, [R3]				; Store new Tick_Count to address of the Tick_Count
				LDR  R3, =INDEX_INPUT_DS	; Address of INDEX_INPUT_DS -> R3
				LDR  R3, [R3]				; INDEX_INPUT_DS -> R3
				LSLS R3, R3, #2				; Multiply R3 with 4 
				LDR  R4, =IN_DATA			; Starting address of the Input Data -> R4
				LDR  R4, [R4, R3]			; Move forward in input data area as index * 4 in bytes and get the next input data
				LDR  R5, =IN_DATA_FLAG		; Starting address of the Input Data Flag -> R5
				LDR  R5, [R5, R3]			; Move forward in input data flag area as index * 4 in bytes and get the next input data flag
				MOVS R0, R4	 				; Set input data address in R0 as send parameter
				PUSH {R0}					; Push input data to stack 
				CMP  R5, #0					; Check if operation is remove
				BEQ  REMOVELABEL			; If yes go to REMOVELABEL
				B 	 COMPARE1				; Else go to next if statement
REMOVELABEL		BL   Remove					; Go to Remove operation 	
				MOVS R1, R0					; Fill R1 with input data to send error
				MOVS R2, #0					; Fill R2 with 0 which is operation flag of remove operation 
				B 	 CHECK_ERROR			; Check if there is any error
COMPARE1		CMP  R5, #1					; Check if operation is insert
				BEQ  INSERTLABEL			; If yes go to INSERTLABEL
				B 	 COMPARE2				; Else go to next if statement
INSERTLABEL		BL   Insert					; Go to Insert operation
				MOVS R1, R0					; Fill R1 with input data to send error
				MOVS R2, #1					; Fill R2 with 1 which is operation flag of insert operation 
				B 	 CHECK_ERROR			; Check if there is any error
COMPARE2		CMP  R5, #2					; Check if operation is linked list to array
				BEQ  LIST2ARR				; If yes go to LIST2ARR
				B    OP_NOT_FOUND			; Else go to not found statement
LIST2ARR 		BL 	 LinkedList2Arr			; Go to linked list to array operation
				MOVS R1, R0					; Fill R1 with input data to send error
				MOVS R2, #2					; Fill R2 with 2 which is operation flag of linked list to array operation
CHECK_ERROR		POP {R3}					; Pop input data from stack and put it to R3 
				CMP R0, #0					; Check if the operations return an error
				BEQ INCINDEX_INPUT			; If not then go to increasing input data index function
				B 	WRITE_ERROR				; Else go to error write function
OP_NOT_FOUND	MOVS R1, #6					; Fill R1 with 6 which means operation not found in error codes table
				MOVS R2, R5					; Fill R2 with operation code
				POP {R3}					; Pop LR and Return
WRITE_ERROR		LDR R0, =INDEX_INPUT_DS		; Assign R0 to index input address
				LDR R0, [R0]				; Assign R0 to index input value
				BL	WriteErrorLog			; Go to error writing function
INCINDEX_INPUT	LDR  R3, =INDEX_INPUT_DS	; Get input index address in R3
				LDR  R4, [R3]				; Get input index value in R4
				ADDS R4, R4, #1				; Incremenet input index value by one
				STR  R4, [R3]				; Store updated input index value
				LDR  R3, =END_IN_DATA		; Get the end point of the input data
				LDR  R5, =IN_DATA			; Get the starting point of the input data
				SUBS R3, R3, R5				; Get their difference
				LSRS R3, R3, #2				; Divide it by 4 to get rid of address size
				CMP	 R3, R4					; Check if result is equal to current index of input data set
				BNE	 handler_stop			; If no, go to handler stop
				BL  SysTick_Stop			; Else, go to systick stop 
handler_stop	POP  {PC}					; pop LR to pc from stack
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------															
				LDR  R0, =0xE000E010		; it takes system tick control memory address
				LDR  R1, =60543				; keeps reload value
				STR  R1, [R0, #4]			; stores reload value into memory
				MOVS R1, #0					; keeps current value as 0
				STR  R1, [R0, #8]			; stores current value into memory
				MOVS R1, #7					; sets flags as 1 (enable, tickint, clksource)
				STR  R1, [R0]				; stores flags in proper memory address
				MOVS R0, #1					; keeps program status value as 1 (timer started)
				LDR  R1, =PROGRAM_STATUS	; takes address of program status variable
				STR  R0, [R1]				; writes 1 to program status
				BX   LR						; branches with link register
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR  R0, =0xE000E010		; it takes system tick control memory address
				MOVS R1, #4					; sets flags as 100 (enable=0, tickint=0, clksource=1)
				STR  R1, [R0]				; stores flags in proper memory address
				MOVS R0, #2					; keeps program status value as 2 (All data operations finished.)					
				LDR  R1, =PROGRAM_STATUS	; takes address of program status variable		
				STR  R0, [R1]				; writes 2 to program status
				BX   LR						; branches with link register
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				MOVS R0, #0 				; Set R0: i = 0
				MOVS R3, #0 				; Set R3 as 0
				LDR  R1, =AT_SIZE 			; get Allocation Table size 
				LDR  R2, =__AT_Start 		; get Allocation Table's address
				B	 COMPARECLEAR 			; branch to compareclear label
LOOPCLEAR		STR  R3, [R2,R0] 			; clear the allocation table's R2th address's R0th index
				ADDS R0, R0, #4 			; increase the index counter
COMPARECLEAR	CMP	 R0, R1 				; compare index and allocation table size
				BNE	 LOOPCLEAR 				; if not equal branch to LOOPCLEAR label
				BX	 LR						; branches with link register
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				MOVS R0, #0					; Set R0: i = 0
				MOVS R3, #0					; Set R3 as 0
				LDR  R1, =LOG_ARRAY_SIZE 	; get log array size 
				LDR  R2, =__LOG_Start  		; get log array's address
				B	 COMPAREERCLEAR 		; branch to compareerclear label
LOOPERCLEAR		STR  R3, [R2,R0]  			; clear the log array's R2th address's R0th index
				ADDS R0, R0, #4 			; increase the index counter
COMPAREERCLEAR	CMP	 R0, R1  				; compare index and log array size
				BNE	 LOOPERCLEAR 			; if not equal branch to LOOPERCLEAR label
				BX	 LR						; branches with link register
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------															
				
				MOVS R0, #0

				;TICK_COUNT is initialized with #0
				LDR R1, =TICK_COUNT 		
				STR R0, [R1]
				
				;FIRST_ELEMENT is initialized with #0
				LDR R1, =FIRST_ELEMENT		
				STR R0, [R1]
				
				;INDEX_INPUT_DS is initialized with #0
				LDR R1, =INDEX_INPUT_DS		
				STR R0, [R1]
				
				;INDEX_ERROR_LOG is initialized with #0
				LDR R1, =INDEX_ERROR_LOG		
				STR R0, [R1]
				
				;PROGRAM_STATUS is initialized with #0
				LDR R1, =PROGRAM_STATUS		
				STR R0, [R1]
				
				BX  LR			;branch with link register
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				MOVS R4, #0					; initializes i with 0
				LDR  R6, =AT_SIZE			; takes size of the allocation table 
				LDR  R7, =__AT_Start		; takes start address of the allocation table
				B	 COMPARESEARCH			; branches to compare label
SEARCH			LDR  R5, [R7,R4]			; takes current word (32-bit) to R5
				MOVS R2, #0					; initializes j with 0
				MOVS R3, #1					; creates mask value with 1
				B	 COMPAREWORD			; branches to compare word
LOOPWORD		MOVS R1, R3					; movs mask value to R1
				ANDS R1, R5, R1				; maskes current word with 1 (checks first bit)
				CMP  R1, #0					; compares masked value with 0
				BNE  NOTFOUND				; if it is not 0, it means that current bit is not empty
				ORRS R5, R5, R3				; if it free area, it allocates current bit with OR operation 
				STR  R5, [R7,R4]			; stores allocated word to memory
				B	 FOUND					; branches to found label				
NOTFOUND		ADDS R2, R2, #1				; increments j with 1
				LSLS R3, R3, #1				; shifts mask value with 1
COMPAREWORD		CMP	 R2, #32				; compares j with 32
				BNE	 LOOPWORD				; if not equal, it continues to iterating			
				ADDS R4, R4, #4				; incements i with 4 byte
COMPARESEARCH	CMP	 R4, R6					; compares i with allocation table size
				BNE	 SEARCH					; if not equal, branches to search word				
				MOVS R0, #0					; meaning that the linked list is full.
				B end_Malloc				; bracnhes to end of the sunction 
FOUND			LSLS R4, R4, #3				; it shifts index number with word number*32
				ADDS R4, R4, R2				; it adds j value to index number
				LDR  R6, =__DATA_Start		; takes data start address 
				LSLS R4, R4, #3				; it multiplies index value with 8 (each node is 8 byte)
				ADDS R6, R4					; it reaches to allocates node
				MOVS R0, R6					; returns allocated node address
end_Malloc		BX   LR						; branches with link register
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				LDR  R6, =__DATA_Start		; Starting address of the data -> R6
				MOVS R3, R0					; Input data -> R3
				SUBS R3, R3, R6  			; Get difference between given node and start address
				LSRS R3, R3, #3 			; Divide difference by 8 to find order of the given address
				MOVS R4, R3					; Copy order to R4
				LSRS R5, R3, #5 			; Divide the order by 32 to get line number
				LSLS R3, R5, #5				; Multiply line number with 32
				SUBS R4, R4, R3				; Get bit number in the line by subtracting 32 times line number from exact order number 
				LDR  R7, =__AT_Start		; Starting address of the Allocation Table -> R7
				LSLS R5, R5, #2				; Multiply line with 4 
				LDR	 R2, =0xFFFFFFFE		; Create 1111 1111 1111 1110 number
				MOVS R6, #32				; Assign 32 to R6
				SUBS R4, R6, R4				; 32 - bit number 
				RORS R2, R2, R4				; Do circular shift for 32 - bit number times
				LDR  R3, [R7, R5]			; Store current line data to R3
				ANDS R3, R3, R2				; Current line data && updated lien data
				STR  R3, [R7, R5]			; Store new line data to allocation in allocation table
				BX   LR						; branches with link register
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------															
				PUSH {LR}					;push LR to stack to protect its value
				MOV R3, R0					;mov the given data parameter to R3
				LDR R1, =FIRST_ELEMENT		;R1 = address of the FIRST_ELEMENT global variable
				LDR R2, [R1]				;R2 = address of the first node 
				CMP R2, #0					;check if first node is null
				BNE is_not_empty			;if it is not null go to is_not_empty label
				PUSH {R1-R3}				;push {R1-R3} to stack to protect its value
				BL Malloc					;go to Malloc label and return the address of the new node in R0
				POP {R1-R3}					;pop {R1-R3} from stack with their old values
				CMP R0, #0					;check if R0 is #0
				BEQ ERROR1					;if it is 0 that means allocation table is full, so go to ERROR1 label
				STR R3, [R0]				;new_node->data = R3 (R3 is given data parameter)
				STR R0, [R1]				;FIRST_ELEMENT = address of the new node
				MOVS R2, #0					;R2 = 0
				STR R2, [R0, #4]			;new_node->nextAddress = #0,because it is the only node in linked list
				B success					;go to success label
is_not_empty	LDR R5, [R1]				;R5 = address of the first node
				LDR R5, [R5]				;R5 = first_node->data
				CMP R3, R5					;compare the given data parameter with data of first_node
				BHI greater					;if the new data is greater than the data of first node go to greater label, else insert as first node
				BEQ	ERROR2					;if they are equal that means the given data is already in linked list, go to ERROR2 label
				PUSH {R1-R3}				;push {R1-R3} to stack to protect its value
				BL 	Malloc					;go to Malloc label and return the address of the new node in R0
				POP {R1-R3}					;pop {R1-R3} from stack with their old values
				CMP R0, #0					;check if R0 is #0
				BEQ ERROR1					;if it is 0 that means allocation table is full, so go to ERROR1 label
				STR R3, [R0]				;new_node->data = R3 (R3 is given data parameter)
				LDR R2, [R1]				;R2 = address of the first node
				STR R2, [R0, #4]			;new_node's nextAddress is equal to address of first element
				STR R0, [R1]				;FIRST_ELEMENT = address of the new node, because we inserted at start of the linked list
				B 	success					;go to success label
greater			LDR R5, [R1]  	 			;R5 = tail 
				LDR R6, [R5, #4]			;R6 = traverser
while_label		CMP R6, #0		 			;check whether it reaches end of the linked list or not
				BEQ	insert_to_end			;if it reaches go to insert_to_end label
				LDR R4, [R6]				;R4 = data of the node that is pointed by traverser
				CMP R3, R4					;compare the given data parameter with data of the current node
				BEQ ERROR2					;if they are equal that means the given data is already in linked list, go to ERROR2 label
				BHI while_end				;if R3>R4, we need to continue to our search operation
				PUSH {R3, R5, R6}			;push {R3, R5, R6} to stack to protect its value		
				BL 	Malloc					;go to Malloc label and return the address of the new node in R0
				POP {R3, R5, R6}			;pop {R3, R5, R6} from stack with their old values
				CMP R0, #0					;check if R0 is #0
				BEQ ERROR1					;if it is 0 that means allocation table is full, so go to ERROR1 label
				STR R3, [R0]				;new_node->data = new data (parameter)
				STR R0, [R5, #4]			;tail->next = address of the new node
				STR R6, [R0, #4]			;new_node->next = traverser
				B success					;branch to success label
while_end		MOVS R5, R6					;tail = traverser
				LDR R6, [R6, #4]			;traverser = traverser->next
				B while_label				;branch to start of the loop
insert_to_end	PUSH {R3, R5}				;push {R3, R5} to stack to protect its value
				BL Malloc					;go to Malloc label and return the address of the new node in R0
				POP {R3, R5}				;pop {R3, R5} from stack with their old values
				CMP R0, #0					;check if R0 is #0
				BEQ ERROR1					;if it is 0 that means allocation table is full, so go to ERROR1 label
				STR R3, [R0]				;new_node->data = new data (parameter)
				STR R0, [R5, #4]			;tail->next = address of the new node
				MOVS R7, #0					;R7 = 0
				STR R7, [R0, #4]			;new_node->next = #0, because it is the new last node in linked list
				B success					;branch to success label
ERROR1			MOVS R0, #1					;R0 = 1 (error code)
				B end_insert				;branch to end_insert label
ERROR2			MOVS R0, #2					;R0 = 2 (error code)
				B end_insert				;branch to end_insert label
success			MOVS R0, #0					;R0 = 0 (success)	
end_insert		POP {PC}					;pop LR to pc from stack
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				PUSH {LR}					;push LR to stack to protect its value
				MOVS R1, R0					;mov the given data parameter to R1
				LDR  R2, =FIRST_ELEMENT		;R2 is the address of FIRST_ELEMENT global variable
				LDR  R3, =FIRST_ELEMENT		;R3 is the address of FIRST_ELEMENT global variable
				LDR  R3, [R3]				;R3 = address of the first node
				CMP  R3, #0					;check if R3 = 0 for empty linked list check
				BEQ  ERROR3					;if linked list is empty branch to ERROR3 label
				LDR  R5, [R3]				;R5 = address of the first node
				CMP  R1, R5					;compare the given data parameter with data of the first node
				BEQ  REMOVEFIRST			;if they are equal branch to REMOVEFIRST label to remove the first node
FINDTARGET		CMP  R3, #0					;check if it reaches end of the linked list
				BEQ  ERROR4					;if we reach end of the linked list that means the given is not in linked list, so branch to ERROR4 label
				LDR  R4, [R3]				;R4 = data of the current node 
				CMP  R1, R4					;check if it is the target data
				BEQ  REMOVENODE				;if current data is equal to data that will be deleted, branch to REMOVENODE label
				MOVS R2, R3					;R2 = R3 (current node)
				LDR  R3, [R3, #4]			;R3 = R3->next (R3 is the traverser to iterate over linked list)
				B 	 FINDTARGET				;branch to FINDTARGET label to continue search operation
REMOVEFIRST 	LDR  R6, [R3, #4]			;R6 is loaded with the address of the second node
				LDR  R7, =FIRST_ELEMENT		;R7 is the address of FIRST_ELEMENT global variable
				STR  R6, [R7]				;FIRST_ELEMENT = R6 (address of the second node)
				MOVS R0, R3					;R0 = address of the deleted node
				B 	 CALLFREE				;branch to CALLFREE label
REMOVENODE 		LDR  R5, [R3, #4]			;R5 = address of the next node of deleted node
				LDR  R0, [R2, #4]			;R0 = address of the deleted node for Free operation
				STR  R5, [R2, #4]			;previous_node->next = deletednode->next
CALLFREE		BL   Free					;branch to Free label
				MOVS R0, #0					;R0 = 3 (success)
				B END_REMOVE				;branch to END_REMOVE label
ERROR3			MOVS R0, #3					;R0 = 3 (error code)
				B END_REMOVE				;branch to END_REMOVE label
ERROR4			MOVS R0, #4					;R0 = 4 (error code)
END_REMOVE		POP {PC}					;pop LR to pc from stack
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															
				LDR  R0, =FIRST_ELEMENT 	; get the first element's address's address
				LDR  R0, [R0] 				; get firs element's address
				CMP  R0, #0 				; if it is compare if it is null
				BEQ  ERROR5 				; if it is null linkedlist is empty then branch to error5 label
				MOVS R0, #0 				; set R0: i = 0
				LDR  R1, =ARRAY_MEM			; get start address of the array
				LDR  R2, =__ARRAY_END 		; get end address of the array 
LOOPSTART		CMP  R1, R2 				; compare if our traversed address is end adress
				BEQ  L2ARR 					; if they are equal that means we cleared array succesfully
				STR  R0, [R1] 				; clear each addresses value
				ADDS R1, R1, #4 			; traverse the addresses
				B 	 LOOPSTART 				; branch to LOOPSTART label and loop all the array
L2ARR			LDR  R0, =FIRST_ELEMENT 	; get the head of the first element
				LDR  R0, [R0] 				; get address of the first element
				LDR  R1, =ARRAY_MEM 		; get the start address of the array	
L2ARRLOOP		CMP  R0, #0 				; compare if nodes address is null
				BEQ  L2ARR_SUCCESS 			; branch to L2ARR_SUCCESS label
				LDR  R2, [R0] 				; get the data from R0 
				STR  R2, [R1] 				; store the data to array
				ADDS R1, R1, #4 			; increment array address
				LDR  R3, [R0, #4] 			; get the next node's address to R3 
				MOVS R0, R3 				; MOV R3 to R0 to make comparison
				B 	 L2ARRLOOP 				; branch to L2ARRLOOP
ERROR5			MOVS R0, #5 				; if linkedlist is empty set error code to 5
				B 	END_L2ARR 				; end Link list to array with errorcode 5
L2ARR_SUCCESS	MOVS R0, #0 				; if all operations are success error code is 0 which means no error
END_L2ARR		BX LR 					    ; branches with link register
;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				PUSH {LR}					; Store LR to stack
				LDR R4, =LOG_MEM			; Get Start of Log memory area
				LDR R5, =INDEX_ERROR_LOG	; Get the address of the Index of error
				LDR R5, [R5]				; Get the value of the index of error
				MOVS R7, #12				; Fill R7 with 12
				MULS R5, R7, R5				; Multiply Index and 12 to get address address distance  
				ADDS R5, R5, R4				; Add distance and start address so, get the current address
				LDR R7, =__LOG_END			; Get the address of end of the Log memory area
				CMP R7, R5					; Check if reached end of the memory of error log
				BEQ	end_writelog			; If yes call end_writelog
				; Else
				STRH R0, [R5]				; Store index which comes as parameter in the first 16-bit
				STRB R1, [R5, #2]			; Store error code which comes as parameter in next 8-bit
				STRB R2, [R5, #3]			; Store operation which comes as parameter in next 8-bit
				STR  R3, [R5, #4]			; Store data which comes as parameter in next 32-bit	
				BL   GetNow					; Call GetNow and get Current System Tick Timer working time 
				STR  R0, [R5, #8]			; Store it in next 32-bit
				LDR R5, =INDEX_ERROR_LOG	; Get the address of the Index of error
				LDR  R6, [R5]				; Get the value of the index of error
				ADDS R6, R6, #1				; Increase index by 1
				STR  R6, [R5]				; Update index data
end_writelog	POP  {PC}					; pop LR to pc from stack
				
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				; get_now = interrupt_period * tick_count + (reload+1-current)/F_cpu
				LDR  R3, =0xE000E018		; load address of the current value to R3 register
				LDR  R3, [R3]				; load current value from current_value address to R3 register
				LDR  R0, =TICK_COUNT		; takes address of TICK_COUNT variable to R0 register		
				LDR  R0, [R0]				; reads value of the tick count from address of the TICK_COUNT
				LDR  R1, =60544				; set R1 with (reload+1)
				SUBS R4, R1, R3				; subtract (current_value) from (reload + 1) and assign to R4 register
				LSRS R4, #6					; divide (R4 register) (reload+1-current) by 64 
				LDR  R2, =946				; set R2 with the Period Of the System Tick Timer Interrupt
				MULS R2, R0, R2				; Multiply interrupt_period with tick_count
				ADDS R0, R2, R4				; and calculate time interrupt_period * tick_count + (reload+1-current)/F_cpu
				BX 	 LR						; branches with link register
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															

;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

